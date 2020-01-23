defmodule ExRets.LoginResponse do
  @moduledoc """
  Information necessary for a client to issue other requests.

  Includes URIs that may be used for other RETS requests, and may also contain identity and
  parameter information if required by the functions supported by the server.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.BaseXmlParser
  alias ExRets.CapabilityUris
  alias ExRets.HttpClient.Httpc
  alias ExRets.RetsResponse
  alias ExRets.SessionInformation

  @typedoc "Information necessary for a client to issue other requests."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          session_information: SessionInformation.t(),
          capability_uris: CapabilityUris.t()
        }

  defstruct session_information: %SessionInformation{}, capability_uris: %CapabilityUris{}

  @typedoc "Key-value format used in the login response body."
  @typedoc since: "0.1.0"
  @type key_value_body :: String.t()

  @doc false
  @doc since: "0.1.0"
  def parse(stream, login_uri, http_client_implementation \\ Httpc) do
    event_state = %{
      characters: [],
      login_uri: login_uri,
      rets_response: %RetsResponse{}
    }

    with {:ok, %{rets_response: rets_response}} <-
           BaseXmlParser.parse(stream, &event_fun/3, event_state, http_client_implementation) do
      {:ok, rets_response}
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
