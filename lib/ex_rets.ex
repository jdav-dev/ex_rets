defmodule ExRets do
  @moduledoc since: "0.1.0"

  require Logger

  alias ExRets.CapabilityUris
  alias ExRets.Credentials
  alias ExRets.HttpClient.Httpc
  alias ExRets.HttpRequest
  alias ExRets.LoginResponse
  alias ExRets.Middleware
  alias ExRets.RetsClient
  alias ExRets.SearchArguments
  alias ExRets.SearchResponse

  @typedoc "RETS client."
  @typedoc since: "0.1.0"
  @opaque client :: RetsClient.t()

  @doc since: "0.1.0"
  def start_client(%Credentials{} = credentials, opts \\ []) do
    http_client_implementation = Keyword.get(opts, :http_client_implementation, Httpc)
    http_timeout = Keyword.get(opts, :timeout, :timer.minutes(15))

    with {:ok, http_client} <- http_client_implementation.start_client(credentials.system_id) do
      middleware = [
        {Middleware.DefaultHeaders, credentials},
        {Middleware.Login, credentials},
        {Middleware.AuthHeaders, credentials},
        Middleware.Logger
      ]

      rets_client = %RetsClient{
        credentials: credentials,
        http_client: http_client,
        http_client_implementation: http_client_implementation,
        http_timeout: http_timeout,
        middleware: middleware
      }

      {:ok, rets_client}
    end
  end

  @doc since: "0.1.0"
  def stop_client(%RetsClient{
        http_client: http_client,
        http_client_implementation: http_client_implementation
      }) do
    http_client_implementation.stop_client(http_client)
  end

  @doc since: "0.1.0"
  def login(%RetsClient{} = rets_client) do
    rets_client
    |> login_fun()
    |> Task.async()
    |> Task.await(:infinity)
  end

  defp login_fun(%RetsClient{} = rets_client) do
    fn ->
      login_uri = rets_client.credentials.login_uri
      request = %HttpRequest{uri: login_uri}
      http_client_implementation = rets_client.http_client_implementation

      with {:ok, _response, stream} <- Middleware.open_stream(rets_client, request),
           {:ok, rets_response} <-
             LoginResponse.parse(stream, login_uri, http_client_implementation) do
        {:ok, %RetsClient{rets_client | login_response: rets_response.response}}
      end
    end
  end

  @doc since: "0.1.0"
  def search(
        %RetsClient{
          login_response: %LoginResponse{
            capability_uris: %CapabilityUris{search: %URI{}}
          }
        } = rets_client,
        search_arguments
      ) do
    rets_client
    |> search_fun(search_arguments)
    |> Task.async()
    |> Task.await(:infinity)
  end

  def search(_not_logged_in_rets_client, _search_arguments), do: {:error, :not_logged_in}

  defp search_fun(%RetsClient{} = rets_client, search_arguments) do
    fn ->
      search_uri = rets_client.login_response.capability_uris.search
      body = SearchArguments.encode_query(search_arguments)
      request = %HttpRequest{method: :post, uri: search_uri, body: body}
      http_client_implementation = rets_client.http_client_implementation

      with {:ok, _response, stream} <- Middleware.open_stream(rets_client, request) do
        SearchResponse.parse(stream, http_client_implementation)
      end
    end
  end
end
