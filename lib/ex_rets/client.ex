defmodule ExRets.Client do
  require Logger

  alias ExRets.CapabilityUris
  alias ExRets.Credentials
  alias ExRets.HttpAuthentication
  alias ExRets.HttpClient
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse
  alias ExRets.LoginResponse
  alias ExRets.SearchArguments
  alias ExRets.SearchResponse

  @typep middleware ::
           (Request.t(), next :: middleware() -> {:ok, Response.t()} | {:error, any()})

  @opaque t :: %__MODULE__{
            credentials: Credentials.t(),
            http_client: HttpClient.t(),
            http_timeout: non_neg_integer() | :infinity,
            login_response: LoginResponse.t(),
            middleware: [middleware()]
          }

  defstruct [:credentials, :http_client, :http_timeout, :login_response, :middleware]

  @ex_rets_version Mix.Project.config() |> Keyword.fetch!(:version)
  @default_user_agent "ExRets/#{@ex_rets_version}"

  def start_client(%Credentials{} = credentials, opts \\ []) do
    http_timeout = Keyword.get(opts, :timeout, :timer.minutes(15))

    with {:ok, http_client} <- HttpClient.start_client(credentials.system_id) do
      middleware = [
        default_headers_middleware_fun(credentials),
        login_middleware_fun(credentials),
        auth_headers_middleware_fun(credentials),
        &logger_middleware/2
      ]

      rets_client = %__MODULE__{
        credentials: credentials,
        http_client: http_client,
        http_timeout: http_timeout,
        middleware: middleware
      }

      {:ok, rets_client}
    end
  end

  defp default_headers_middleware_fun(credentials) do
    default_headers = [
      {"user-agent", credentials.user_agent || @default_user_agent},
      {"rets-version", credentials.rets_version},
      {"accept", "*/*"}
    ]

    fn %HttpRequest{headers: headers} = request, next ->
      %HttpRequest{request | headers: headers ++ default_headers}
      |> next.()
    end
  end

  defp login_middleware_fun(credentials) do
    fn %HttpRequest{} = request, next ->
      case next.(request) do
        {:error, :not_logged_in} ->
          login_uri = credentials.login_uri
          login_request = %HttpRequest{uri: login_uri}

          case next.(login_request) do
            {:ok, _} -> next.(request)
            result -> result
          end

        result ->
          result
      end
    end
  end

  defp auth_headers_middleware_fun(credentials) do
    fn %HttpRequest{} = request, next ->
      with {:ok, %HttpResponse{status: 401} = response} <- next.(request),
           {:ok, updated_request} <-
             HttpAuthentication.answer_challenge(request, response, credentials) do
        next.(updated_request)
      else
        false -> {:error, :not_logged_in}
        result -> result
      end
    end
  end

  defp logger_middleware(%HttpRequest{} = request, next) do
    request_id = generate_request_id()
    Logger.debug("RETS request:\n#{inspect(request, pretty: true)}", request_id: request_id)
    result = next.(request)

    case result do
      {:ok, response, _stream} ->
        Logger.debug("Begin RETS response:\n#{inspect(response, pretty: true)}",
          request_id: request_id
        )

      {:ok, response} ->
        Logger.debug("RETS response:\n#{inspect(response, pretty: true)}", request_id: request_id)

      error ->
        Logger.error("RETS request failed:\n#{inspect(error, pretty: true)}")
    end

    result
  end

  defp generate_request_id do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    Base.url_encode64(binary)
  end

  def stop_client(%__MODULE__{http_client: http_client}) do
    HttpClient.stop_client(http_client)
  end

  def login(%__MODULE__{} = rets_client) do
    rets_client
    |> login_fun()
    |> Task.async()
    |> Task.await(:infinity)
  end

  defp login_fun(%__MODULE__{} = rets_client) do
    fn ->
      login_uri = rets_client.credentials.login_uri
      request = %HttpRequest{uri: login_uri}

      with {:ok, _response, stream} <- open_stream(rets_client, request),
           {:ok, rets_response} <- LoginResponse.parse(stream, login_uri) do
        {:ok, %__MODULE__{rets_client | login_response: rets_response.response}}
      end
    end
  end

  defp open_stream(%__MODULE__{http_timeout: timeout} = rets_client, request) do
    open_stream_fun = fn request ->
      HttpClient.open_stream(rets_client.http_client, request, timeout: timeout)
    end

    run =
      rets_client.middleware
      |> Enum.reverse()
      |> Enum.reduce(open_stream_fun, fn middleware, next ->
        fn request -> middleware.(request, next) end
      end)

    run.(request)
  end

  def search(
        %__MODULE__{
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

  defp search_fun(%__MODULE__{} = rets_client, search_arguments) do
    search_uri = rets_client.login_response.capability_uris.search

    fn ->
      body = SearchArguments.encode_query(search_arguments)
      request = %HttpRequest{method: :post, uri: search_uri, body: body}

      with {:ok, _response, stream} <- open_stream(rets_client, request) do
        SearchResponse.parse(stream)
      end
    end
  end
end
