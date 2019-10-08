defmodule ExRets.LoginResponse do
  alias ExRets.{CapabilityUris, RetsResponse, SessionInformation}

  @type t :: %__MODULE__{
          session_information: SessionInformation.t(),
          capability_uris: CapabilityUris.t()
        }

  defstruct session_information: %SessionInformation{}, capability_uris: %CapabilityUris{}

  def parse(xml, login_uri) do
    xml = to_charlist(xml)

    initial_event_state = %{
      rets_response: %RetsResponse{response: %__MODULE__{}},
      characters: [],
      login_uri: login_uri
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

  defp xmerl_event_fun({:startElement, _, _name, _, _attributes}, _, state) do
    put_in(state.characters, [])
  end

  defp xmerl_event_fun({:characters, characters}, _, state) do
    put_in(state.characters, [characters | state.characters])
  end

  defp xmerl_event_fun({:endElement, _, 'RETS-RESPONSE', _}, _, state) do
    key_value_body = state.characters |> Enum.reverse() |> Enum.join("")

    login_response = %__MODULE__{
      session_information: SessionInformation.parse(key_value_body),
      capability_uris: CapabilityUris.parse(key_value_body, state.login_uri)
    }

    put_in(state.rets_response.response, login_response)
  end

  defp xmerl_event_fun(_event, _, state), do: state
end
