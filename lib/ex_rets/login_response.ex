defmodule ExRets.LoginResponse do
  alias ExRets.CapabilityUris
  alias ExRets.HttpClient
  alias ExRets.RetsResponse
  alias ExRets.SessionInformation

  @type t :: %__MODULE__{
          session_information: SessionInformation.t(),
          capability_uris: CapabilityUris.t()
        }

  defstruct session_information: %SessionInformation{}, capability_uris: %CapabilityUris{}

  def parse(stream, login_uri) do
    event_state = %{
      characters: [],
      login_uri: login_uri,
      rets_response: %RetsResponse{}
    }

    opts = [
      continuation_fun: &continuation_fun/1,
      continuation_state: stream,
      event_fun: &event_fun/3,
      event_state: event_state
    ]

    with {:ok, xml} <- HttpClient.stream_next(stream),
         {:ok, %{rets_response: rets_response}, _} <- :xmerl_sax_parser.stream(xml, opts) do
      {:ok, rets_response}
    end
  end

  defp continuation_fun(stream) do
    case HttpClient.stream_next(stream) do
      {:ok, xml} -> {xml, stream}
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

  defp event_fun({:startElement, _, _name, _, _attributes}, _, state) do
    put_in(state.characters, [])
  end

  defp event_fun({:characters, characters}, _, state) do
    put_in(state.characters, [characters | state.characters])
  end

  defp event_fun({:endElement, _, 'RETS-RESPONSE', _}, _, state) do
    key_value_body = state.characters |> Enum.reverse() |> Enum.join("")

    login_response = %__MODULE__{
      session_information: SessionInformation.parse(key_value_body),
      capability_uris: CapabilityUris.parse(key_value_body, state.login_uri)
    }

    put_in(state.rets_response.response, login_response)
  end

  defp event_fun(_event, _, state), do: state
end
