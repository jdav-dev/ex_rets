defmodule ExRets.HttpRequest do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.HttpClient.Httpc

  @enforce_keys [:uri]
  defstruct method: :get, uri: nil, headers: [], body: nil

  @type t :: %__MODULE__{
          method: :get | :post,
          uri: URI.t(),
          headers: ExRets.HttpClient.headers(),
          body: String.t() | nil
        }

  @doc false
  @spec to_httpc(t()) :: Httpc.request()
  def to_httpc(%__MODULE__{} = request) do
    uri = to_string(request.uri)
    headers = Enum.map(request.headers, fn {k, v} -> {to_charlist(k), to_charlist(v)} end)
    body = request.body

    if request.method == :post and is_binary(body) do
      {content_type, headers} = split_content_type_from_headers(headers)
      {uri, headers, content_type, body}
    else
      {uri, headers}
    end
  end

  defp split_content_type_from_headers(headers) do
    case List.keytake(headers, ~c"content-type", 0) do
      nil -> {~c"text/plain", headers}
      {{_, ct}, headers} -> {ct, headers}
    end
  end
end
