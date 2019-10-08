defmodule ExRets.CapabilityUris do
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

  def parse(key_value_body, %URI{} = login_uri) do
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

  defp parse_login_response(element, login_uri) when is_binary(element) do
    element
    |> String.split("\n")
    |> Enum.reduce(%{}, map_response_arguments(login_uri))
  end

  defp parse_login_response(_, _), do: %{}

  defp map_response_arguments(login_uri) do
    fn argument, acc ->
      case String.split(argument, "=") do
        [key, value] ->
          lowercase_key = String.downcase(key)
          uri_value = %URI{login_uri | path: value}
          Map.put(acc, lowercase_key, uri_value)

        _ ->
          acc
      end
    end
  end
end
