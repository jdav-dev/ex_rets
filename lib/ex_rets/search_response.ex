defmodule ExRets.SearchResponse do
  alias ExRets.RetsResponse
  alias ExRets.CompactFormat

  @type t :: %__MODULE__{
          count: non_neg_integer(),
          columns: [String.t()],
          rows: [String.t()]
        }

  defstruct count: nil, columns: [], rows: []

  def parse(xml) do
    xml = to_charlist(xml)

    initial_event_state = %{
      rets_response: %RetsResponse{response: %__MODULE__{}},
      delimiter: "\t",
      characters: []
    }

    xmerl_opts = [event_fun: &xmerl_event_fun/3, event_state: initial_event_state]

    with {:ok, %{rets_response: rets_response}, _} <- :xmerl_sax_parser.stream(xml, xmerl_opts) do
      {:ok, rets_response}
    end
  end

  defp xmerl_event_fun({:startElement, _, 'RETS', _, attributes}, _, state) do
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

  defp xmerl_event_fun({:startElement, _, 'COUNT', _, attributes}, _, state) do
    Enum.reduce(attributes, state, fn
      {_, _, 'Records', value}, acc ->
        count = value |> to_string() |> String.to_integer()
        put_in(acc.rets_response.response.count, count)

      _, acc ->
        acc
    end)
  end

  defp xmerl_event_fun({:startElement, _, 'DELIMITER', _, attributes}, _, state) do
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

  defp xmerl_event_fun({:startElement, _, _name, _, _attributes}, _, state) do
    put_in(state.characters, [])
  end

  defp xmerl_event_fun({:characters, characters}, _, state) do
    put_in(state.characters, [characters | state.characters])
  end

  defp xmerl_event_fun({:endElement, _, 'COLUMNS', _}, _, state) do
    columns =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")
      |> CompactFormat.Data.parse()

    put_in(state.rets_response.response.columns, columns)
  end

  defp xmerl_event_fun({:endElement, _, 'DATA', _}, _, state) do
    row =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")
      |> CompactFormat.Data.parse()

    put_in(state.rets_response.response.rows, [row | state.rets_response.response.rows])
  end

  defp xmerl_event_fun(_event, _, state), do: state
end
