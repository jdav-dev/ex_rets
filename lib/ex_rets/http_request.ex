defmodule ExRets.HttpRequest do
  @moduledoc false
  @moduledoc since: "0.1.0"

  @enforce_keys [:uri]
  defstruct method: :get, uri: nil, headers: [], body: nil

  @type t :: %__MODULE__{
          method: :get | :post,
          uri: URI.t(),
          headers: ExRets.HttpClient.headers(),
          body: String.t()
        }

  @doc false
  def to_httpc(%__MODULE__{} = request) do
    uri = request.uri |> to_string() |> to_charlist()
    headers = Enum.map(request.headers, fn {k, v} -> {to_charlist(k), to_charlist(v)} end)

    case request.method do
      :get ->
        {uri, headers}

      :post ->
        {content_type, headers} = split_content_type_from_headers(headers)
        body = to_charlist(request.body)
        {uri, headers, content_type, body}
    end
  end

  defp split_content_type_from_headers(headers) do
    case List.keytake(headers, 'content-type', 0) do
      nil -> {'text/plain', headers}
      {{_, ct}, headers} -> {ct, headers}
    end
  end
end
