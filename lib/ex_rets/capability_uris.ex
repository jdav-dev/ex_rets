defmodule ExRets.CapabilityUris do
  @moduledoc """
  URIs for issuing RETS requests.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.LoginResponse

  defstruct [
    :action,
    :change_password,
    :get_object,
    :login,
    :login_complete,
    :logout,
    :search,
    :get_metadata,
    :update,
    :post_object,
    :get_payload_list
  ]

  @typedoc "URIs for issuing RETS requests."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          action: URI.t() | nil,
          change_password: URI.t() | nil,
          get_object: URI.t() | nil,
          login: URI.t() | nil,
          login_complete: URI.t() | nil,
          logout: URI.t() | nil,
          search: URI.t() | nil,
          get_metadata: URI.t() | nil,
          update: URI.t() | nil,
          post_object: URI.t() | nil,
          get_payload_list: URI.t() | nil
        }

  @doc """
  Parses a capability URL list returned as part of a login response.

  Uses host information from the login URI if a returned capability URL does not include host
  information.

  ## Examples

      iex> login_uri = URI.parse("https://example.com/login")
      iex> ExRets.CapabilityUris.parse("Login = /login\\nSearch = /search", login_uri)
      %ExRets.CapabilityUris{
        login: %URI{
          authority: "example.com",
          host: "example.com",
          path: "/login",
          port: 443,
          scheme: "https"
        },
        search: %URI{
          authority: "example.com",
          host: "example.com",
          path: "/search",
          port: 443,
          scheme: "https"
        }
      }

      iex> login_uri = URI.parse("https://example.com/login")
      iex> ExRets.CapabilityUris.parse("Search = http://different.example.com/search", login_uri)
      %ExRets.CapabilityUris{
        search: %URI{
          authority: "different.example.com",
          host: "different.example.com",
          path: "/search",
          port: 80,
          scheme: "http"
        }
      }
  """
  @doc since: "0.1.0"
  @spec parse(LoginResponse.key_value_body(), URI.t()) :: t()
  def parse(key_value_body, %URI{} = login_uri) when is_binary(key_value_body) do
    params = parse_login_response(key_value_body, login_uri)

    %__MODULE__{
      action: params["action"],
      change_password: params["changepassword"],
      get_object: params["getobject"],
      login: params["login"],
      login_complete: params["logincomplete"],
      logout: params["logout"],
      search: params["search"],
      get_metadata: params["getmetadata"],
      update: params["update"],
      post_object: params["postobject"],
      get_payload_list: params["getpayloadlist"]
    }
  end

  defp parse_login_response(key_value_body, login_uri) do
    key_value_body
    |> String.split("\n")
    |> Enum.reduce(%{}, map_response_arguments(login_uri))
  end

  defp map_response_arguments(login_uri) do
    fn argument, acc ->
      case String.split(argument, "=") do
        [key, value] ->
          normalized_key = trim_and_downcase_string(key)
          uri_value = parse_uri(value, login_uri)
          Map.put(acc, normalized_key, uri_value)

        _ ->
          acc
      end
    end
  end

  defp trim_and_downcase_string(string) do
    string
    |> String.trim()
    |> String.downcase()
  end

  defp parse_uri(value, login_uri) do
    uri_value = value |> String.trim() |> URI.parse()

    case uri_value.host do
      nil -> %URI{login_uri | path: uri_value.path}
      _ -> uri_value
    end
  end
end
