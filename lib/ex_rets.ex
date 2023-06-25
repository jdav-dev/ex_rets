defmodule ExRets do
  @moduledoc """
  RETS client for Elixir.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.CapabilityUris
  alias ExRets.Credentials
  alias ExRets.HttpClient.Httpc
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse
  alias ExRets.LoginResponse
  alias ExRets.LogoutResponse
  alias ExRets.Middleware
  alias ExRets.RetsClient
  alias ExRets.RetsResponse
  alias ExRets.SearchArguments
  alias ExRets.SearchResponse

  require Logger

  @typedoc "RETS client."
  @typedoc since: "0.1.0"
  @opaque client :: RetsClient.t()

  @typedoc "Options for the RETS client."
  @typedoc since: "0.1.0"
  @type opts :: [timeout: integer()]

  @typedoc "Details about why an error occurred."
  @typedoc since: "0.1.0"
  @type reason :: any()

  @doc """
  Open an HTTP client and log in to a RETS server.

  Returns an `:ok` tuple with either a `t:client/0` if the login succeeds, or an
  `t:ExRets.HttpResponse.t/0` if the login attempt ends with a non-200 status code.

  An `:error` tuple is returned for any other issues.

  ## Options

    * `:timeout` - HTTP timeout in seconds, applied to each HTTP request by the client.
  """
  @doc since: "0.1.0"
  @spec login(Credentials.t(), opts()) ::
          {:ok, client()} | {:ok, HttpResponse.t()} | {:error, reason()}
  def login(%Credentials{} = credentials, opts \\ []) do
    with {:ok, rets_client} <- new_rets_client(credentials, opts) do
      rets_client
      |> login_fun()
      |> Task.async()
      |> Task.await(:infinity)
    end
  end

  defp new_rets_client(%Credentials{} = credentials, opts) do
    http_client_implementation = Keyword.get(opts, :http_client_implementation, Httpc)
    http_timeout = Keyword.get(opts, :timeout, :timer.minutes(15))

    middleware = [
      {Middleware.DefaultHeaders, credentials},
      {Middleware.Login, credentials},
      {Middleware.AuthHeaders, credentials},
      Middleware.Logger
    ]

    with {:ok, http_client} <- http_client_implementation.start_client(credentials.system_id) do
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

  @doc """
  Logout and close the HTTP client.

  Returns an `:ok` tuple with either a `t:ExRets.RetsResponse.t/0` if the logout succeeds, or an
  `t:ExRets.HttpResponse.t/0` if the logout ends with a non-200 status code.

  An `:error` tuple is returned for any other issues.
  """
  @doc since: "0.1.0"
  @dialyzer {:no_contracts, logout: 1}
  @spec logout(client()) ::
          {:ok, RetsResponse.t()} | {:ok, HttpResponse.t()} | {:error, reason()}
  def logout(%RetsClient{} = rets_client) do
    rets_client
    |> logout_fun()
    |> Task.async()
    |> Task.await(:infinity)
  end

  defp logout_fun(%RetsClient{} = rets_client) do
    fn ->
      logout_uri = rets_client.login_response.capability_uris.logout
      request = %HttpRequest{uri: logout_uri}
      http_client_implementation = rets_client.http_client_implementation

      with {:ok, _response, stream} <- Middleware.open_stream(rets_client, request),
           :ok <- http_client_implementation.stop_client(rets_client.http_client) do
        LogoutResponse.parse(stream, http_client_implementation)
      end
    end
  end

  @doc """
  Perform a RETS search.

  Returns an `:ok` tuple with either a `t:ExRets.RetsResponse.t/0` if the search succeeds, or an
  `t:ExRets.HttpResponse.t/0` if the search ends with a non-200 status code.

  An `:error` tuple is returned for any other issues.
  """
  @doc since: "0.1.0"
  @dialyzer {:no_contracts, search: 2}
  @spec search(client(), SearchArguments.t()) ::
          {:ok, RetsResponse.t()} | {:ok, HttpResponse.t()} | {:error, reason()}
  def search(
        %RetsClient{
          login_response: %LoginResponse{
            capability_uris: %CapabilityUris{search: %URI{}}
          }
        } = rets_client,
        %SearchArguments{} = search_arguments
      ) do
    rets_client
    |> search_fun(search_arguments)
    |> Task.async()
    |> Task.await(:infinity)
  end

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
