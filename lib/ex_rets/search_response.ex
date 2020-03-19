defmodule ExRets.SearchResponse do
  @moduledoc """
  Records matching a search query.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.BaseXmlParser
  alias ExRets.CompactDelimiter
  alias ExRets.CompactRecord
  alias ExRets.HttpClient
  alias ExRets.RetsResponse

  @typedoc "Records matching a search query."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          count: non_neg_integer() | nil,
          columns: [String.t()],
          rows: [[String.t()]],
          max_rows: max_rows()
        }

  defstruct count: nil, columns: [], rows: [], max_rows: false

  @typedoc """
  `true` if the request results in more matches than the server returns, `false` otherwise.
  """
  @typedoc since: "0.1.0"
  @type max_rows :: boolean()

  @doc false
  @doc since: "0.1.0"
  @spec parse(HttpClient.stream(), HttpClient.implementation()) ::
          {:ok, RetsResponse.t(t())} | {:error, ExRets.reason()}
  def parse(stream, http_client_implementation) do
    event_state = %{
      characters: [],
      delimiter: "\t",
      rets_response: %RetsResponse{response: %__MODULE__{}}
    }

    with {:ok, %{rets_response: rets_response}} <-
           BaseXmlParser.parse(stream, &event_fun/3, event_state, http_client_implementation) do
      rets_response =
        put_in(rets_response.response.rows, Enum.reverse(rets_response.response.rows))

      {:ok, rets_response}
    end
  end

  defp event_fun({:startElement, _, 'RETS', _, attributes}, _, state) do
    updated_rets_response =
      RetsResponse.read_rets_element_attributes(attributes, state.rets_response)

    %{state | rets_response: updated_rets_response}
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

        case CompactDelimiter.decode(value) do
          {:ok, delimiter} -> put_in(acc.delimiter, delimiter)
          :error -> throw({:fatal_error, "Invalid delimiter"})
        end

      _, acc ->
        acc
    end)
  end

  defp event_fun({:startElement, _, 'MAXROWS', _, _attributes}, _, state) do
    put_in(state.rets_response.response.max_rows, true)
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
      |> CompactRecord.decode()

    put_in(state.rets_response.response.columns, columns)
  end

  defp event_fun({:endElement, _, 'DATA', _}, _, state) do
    row =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")
      |> CompactRecord.decode()

    put_in(state.rets_response.response.rows, [row | state.rets_response.response.rows])
  end

  # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/xmerl
  defp event_fun({:internalEntityDecl, _, _}, _, _), do: raise("Entity expansion")
  defp event_fun({:externalEntityDecl, _, _, _}, _, _), do: raise("Entity expansion")

  defp event_fun(_event, _, state), do: state
end
