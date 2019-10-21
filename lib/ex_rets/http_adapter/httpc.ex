defmodule ExRets.HttpAdapter.Httpc do
  alias ExRets.{HttpAdapter, HttpResponse}

  @behaviour HttpAdapter

  @default_httpc_opts [ssl: [ciphers: :ssl.cipher_suites(:all, :"tlsv1.2")]]

  @impl HttpAdapter
  def new_client(opts) do
    with {:ok, profile_name} <- Keyword.fetch(opts, :profile),
         {:ok, profile} <- start_httpc(profile_name),
         :ok <- :httpc.set_options([cookies: :enabled], profile) do
      {:ok, profile}
    else
      :error -> {:error, ":profile option is required"}
      error -> error
    end
  end

  defp start_httpc(profile_name) do
    case :inets.start(:httpc, profile: profile_name) do
      {:error, {:already_started, profile}} -> {:ok, profile}
      result -> result
    end
  end

  @impl HttpAdapter
  def do_request(profile, request, httpc_opts \\ []) do
    httpc_request = new_httpc_request(request)
    http_opts = merge_default_httpc_opts(httpc_opts)
    opts = []

    request.method
    |> :httpc.request(httpc_request, http_opts, opts, profile)
    |> format_response()
  end

  defp new_httpc_request(request) do
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

  defp format_response({:ok, {{_, status, _}, headers, body}}) do
    headers = Enum.map(headers, fn {key, value} -> {to_string(key), to_string(value)} end)
    body = IO.iodata_to_binary(body)

    {:ok, %HttpResponse{status: status, headers: headers, body: body}}
  end

  defp format_response({:error, error}) do
    {:error, error}
  end

  defp merge_default_httpc_opts(opts) do
    Keyword.merge(@default_httpc_opts, opts)
  end

  @impl HttpAdapter
  def close_client(profile) do
    :inets.stop(:httpc, profile)
  end
end
