defmodule ExRets.Client do
  require Logger

  alias ExRets.{Credentials, DigestAuthentication, HttpRequest, HttpResponse}

  @typep middleware ::
           (Request.t(), next :: middleware() -> {:ok, Response.t()} | {:error, any()})

  @opaque t :: %__MODULE__{
            credentials: Credentials.t(),
            http_adapter: ExRets.HttpAdapter.t(),
            http_client: ExRets.HttpAdapter.client(),
            middleware: [middleware()]
          }

  @enforce_keys [:http_client, :credentials, :http_adapter]
  defstruct http_client: nil, credentials: nil, http_adapter: nil, middleware: []

  def new(%Credentials{} = credentials, opts \\ []) do
    http_adapter = Keyword.get(opts, :http_adapter, ExRets.HttpAdapter.Httpc)

    with {:ok, http_client} <- http_adapter.new_client(profile: credentials.mls_id) do
      middleware = [
        default_headers_middleware(credentials),
        http_auth_middleware(credentials),
        &logger_middleware/2
      ]

      rets_client = %__MODULE__{
        credentials: credentials,
        http_adapter: http_adapter,
        http_client: http_client,
        middleware: middleware
      }

      {:ok, rets_client}
    end
  end

  defp default_headers_middleware(credentials) do
    default_headers = [
      {"user-agent", credentials.user_agent},
      {"rets-version", credentials.rets_version},
      {"accept", "*/*"}
    ]

    fn %HttpRequest{headers: headers} = request, next ->
      %HttpRequest{request | headers: headers ++ default_headers}
      |> next.()
    end
  end

  defp http_auth_middleware(credentials) do
    fn %HttpRequest{} = request, next ->
      case next.(request) do
        {:ok, %HttpResponse{status: 401, headers: headers}} ->
          authorization =
            headers
            |> DigestAuthentication.parse_challenge()
            |> DigestAuthentication.answer_challenge(
              credentials.username,
              credentials.password,
              request.method,
              request.uri
            )

          request = %HttpRequest{
            request
            | headers: [{"authorization", to_string(authorization)} | request.headers]
          }

          http_auth_middleware(credentials).(request, next)

        result ->
          result
      end
    end
  end

  defp logger_middleware(%HttpRequest{} = request, next) do
    request_id = generate_request_id()
    Logger.debug("Running request:\n#{inspect(request, pretty: true)}", request_id: request_id)
    result = next.(request)

    case result do
      {:ok, response} ->
        Logger.debug("Response:\n#{inspect(response, pretty: true)}", request_id: request_id)

      error ->
        Logger.error("Request failed:\n#{inspect(error, pretty: true)}")
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

  def do_request(%__MODULE__{} = rets_client, request) do
    call_http_adapter = fn request ->
      rets_client.http_adapter.do_request(rets_client.http_client, request)
    end

    run =
      rets_client.middleware
      |> Enum.reverse()
      |> Enum.reduce(call_http_adapter, fn middleware, next ->
        fn request -> middleware.(request, next) end
      end)

    run.(request)
  end

  def close(%__MODULE__{http_client: http_client, http_adapter: http_adapter}) do
    http_adapter.close_client(http_client)
  end
end
