defmodule ExRets.LogoutResponse do
  @moduledoc """
  Parsed server response from a logout transaction.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.BaseXmlParser
  alias ExRets.HttpClient
  alias ExRets.RetsResponse

  @typedoc "Parsed server response from a logout transaction."
  @typedoc since: "0.1.0"
  @type t :: map()

  @doc false
  @doc since: "0.1.0"
  @spec parse(HttpClient.stream(), HttpClient.implementation()) ::
          {:ok, RetsResponse.t(t())} | {:error, ExRets.reason()}
  def parse(stream, http_client_implementation) do
    event_state = %{
      characters: [],
      rets_response: %RetsResponse{}
    }

    with {:ok, %{rets_response: rets_response}} <-
           BaseXmlParser.parse(stream, &event_fun/3, event_state, http_client_implementation) do
      {:ok, rets_response}
    end
  end

  defp event_fun({:startElement, _, ~c"RETS", _, attributes}, _, state) do
    updated_rets_response =
      RetsResponse.read_rets_element_attributes(attributes, state.rets_response)

    %{state | rets_response: updated_rets_response}
  end

  defp event_fun({:startElement, _, _name, _, _attributes}, _, state) do
    put_in(state.characters, [])
  end

  defp event_fun({:characters, characters}, _, state) do
    put_in(state.characters, [characters | state.characters])
  end

  defp event_fun({:endElement, _, ~c"RETS-RESPONSE", _}, _, state) do
    key_value_body =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "=", parts: 2))
      |> Enum.reduce(%{}, fn
        [k, v], acc -> Map.put(acc, String.trim(k), String.trim(v))
        _, acc -> acc
      end)

    put_in(state.rets_response.response, key_value_body)
  end

  # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/xmerl
  defp event_fun({:internalEntityDecl, _, _}, _, _), do: raise("Entity expansion")
  defp event_fun({:externalEntityDecl, _, _, _}, _, _), do: raise("Entity expansion")

  defp event_fun(_event, _, state), do: state
end
