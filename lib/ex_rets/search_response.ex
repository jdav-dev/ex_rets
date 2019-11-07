defmodule ExRets.SearchResponse do
  alias ExRets.CompactFormat
  alias ExRets.HttpClient
  alias ExRets.RetsResponse

  @type t :: %__MODULE__{
          count: non_neg_integer(),
          columns: [String.t()],
          rows: [String.t()]
        }

  defstruct count: nil, columns: [], rows: []

  def parse(streamer) do
    event_state = %{
      characters: [],
      delimiter: "\t",
      rets_response: %RetsResponse{response: %__MODULE__{}}
    }

    opts = [
      continuation_fun: &continuation_fun/1,
      continuation_state: streamer,
      event_fun: &event_fun/3,
      event_state: event_state
    ]

    with {:ok, xml} <- HttpClient.stream_next(streamer),
         {:ok, %{rets_response: rets_response}, _} <- :xmerl_sax_parser.stream(xml, opts) do
      {:ok, rets_response}
    end
  end

  defp continuation_fun(streamer) do
    case HttpClient.stream_next(streamer) do
      {:ok, xml} -> {xml, streamer}
      {:error, reason} -> throw({:error, reason})
    end
  end

  defp event_fun({:startElement, _, 'RETS', _, attributes}, _, state) do
    Enum.reduce(attributes, state, fn
      {_, _, 'ReplyCode', value}, acc ->
        reply_code = value |> to_string() |> String.to_integer()
        put_in(acc.rets_response.reply_code, reply_code)

      {_, _, 'ReplyText', value}, acc ->
        reply_text = to_string(value)
        put_in(acc.rets_response.reply_text, reply_text)

      _, acc ->
        acc
    end)
  end

  defp event_fun({:startElement, _, 'COUNT', _, attributes}, _, state) do
    Enum.reduce(attributes, state, fn
      {_, _, 'Records', value}, acc ->
        count = value |> to_string() |> String.to_integer()
        put_in(acc.rets_response.response.count, count)

      _, acc ->
        acc
    end)
  end

  defp event_fun({:startElement, _, 'DELIMITER', _, attributes}, _, state) do
    Enum.reduce(attributes, state, fn
      {_, _, 'value', value}, acc ->
        value = to_string(value)

        case CompactFormat.Delimiter.decode(value) do
          {:ok, delimiter} -> put_in(acc.delimiter, delimiter)
          :error -> acc
        end

      _, acc ->
        acc
    end)
  end

  defp event_fun({:startElement, _, _name, _, _attributes}, _, state) do
    put_in(state.characters, [])
  end

  defp event_fun({:characters, characters}, _, state) do
    put_in(state.characters, [characters | state.characters])
  end

  defp event_fun({:endElement, _, 'COLUMNS', _}, _, state) do
    columns =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")
      |> CompactFormat.Data.parse()

    put_in(state.rets_response.response.columns, columns)
  end

  defp event_fun({:endElement, _, 'DATA', _}, _, state) do
    row =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")
      |> CompactFormat.Data.parse()

    put_in(state.rets_response.response.rows, [row | state.rets_response.response.rows])
  end

  defp event_fun(_event, _, state), do: state
end
