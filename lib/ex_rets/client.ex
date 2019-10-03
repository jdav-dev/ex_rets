defmodule ExRets.Client do
  require Logger

  alias ExRets.{
    CapabilityUris,
    Credentials,
    DigestAuthentication,
    HttpRequest,
    HttpResponse,
    LoginResponse,
    RetsResponse,
    SearchArguments,
    SearchResponse,
    SessionInformation
  }

  @typep middleware ::
           (Request.t(), next :: middleware() -> {:ok, Response.t()} | {:error, any()})

  @opaque t :: %__MODULE__{
            capability_uris: CapabilityUris.t() | nil,
            credentials: Credentials.t(),
            http_adapter: ExRets.HttpAdapter.t(),
            http_client: ExRets.HttpAdapter.client(),
            http_timeout: non_neg_integer() | :infinity,
            middleware: [middleware()],
            session_information: SessionInformation.t() | nil
          }

  defstruct capability_uris: nil,
            credentials: nil,
            http_client: nil,
            http_adapter: nil,
            http_timeout: nil,
            middleware: [],
            session_information: nil

  def new(%Credentials{} = credentials, opts \\ []) do
    http_adapter = Keyword.get(opts, :http_adapter, ExRets.HttpAdapter.Httpc)
    http_timeout = Keyword.get(opts, :http_timeout, :timer.seconds(30))
    xml_parser = Keyword.get(opts, :xml_parser, ExRets.XmlParser.Xmerl)

    with {:ok, http_client} <- http_adapter.new_client(profile: credentials.mls_id) do
      middleware = [
        parse_rets_response_middleware(xml_parser),
        default_headers_middleware(credentials),
        http_auth_middleware(credentials),
        &logger_middleware/2
      ]

      rets_client = %__MODULE__{
        credentials: credentials,
        http_adapter: http_adapter,
        http_client: http_client,
        http_timeout: http_timeout,
        middleware: middleware
      }

      {:ok, rets_client}
    end
  end

  defp parse_rets_response_middleware(xml_parser) do
    fn request, next ->
      result = next.(request)

      with {:ok, %HttpResponse{headers: headers, body: body}} <- result,
           true <- {"content-type", "text/xml"} in headers do
        rets_response =
          body
          |> xml_parser.parse()
          |> RetsResponse.from_xml()

        {:ok, rets_response}
      else
        _ -> result
      end
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
    Logger.debug("RETS request:\n#{inspect(request, pretty: true)}", request_id: request_id)
    result = next.(request)

    case result do
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

  def close(%__MODULE__{http_client: http_client, http_adapter: http_adapter}) do
    http_adapter.close_client(http_client)
  end

  def login(%__MODULE__{} = rets_client) do
    login_uri = rets_client.credentials.login_uri
    request = %HttpRequest{uri: login_uri}

    with {:ok, %RetsResponse{} = rets_response} <- do_request(rets_client, request) do
      login_response = LoginResponse.from_rets_response(login_uri, rets_response)

      logged_in_rets_client = %__MODULE__{
        rets_client
        | capability_uris: login_response.capability_uris,
          session_information: login_response.session_information
      }

      {:ok, logged_in_rets_client}
    end
  end

  defp do_request(%__MODULE__{http_timeout: timeout} = rets_client, request) do
    call_http_adapter = fn request ->
      rets_client.http_adapter.do_request(rets_client.http_client, request, timeout: timeout)
    end

    run =
      rets_client.middleware
      |> Enum.reverse()
      |> Enum.reduce(call_http_adapter, fn middleware, next ->
        fn request -> middleware.(request, next) end
      end)

    run.(request)
  end

  def search(
        %__MODULE__{capability_uris: %CapabilityUris{search: %URI{} = search_uri}} = rets_client,
        search_arguments
      ) do
    body = SearchArguments.encode_query(search_arguments)
    request = %HttpRequest{method: :post, uri: search_uri, body: body}

    with {:ok, %RetsResponse{} = rets_response} <- do_request(rets_client, request) do
      {:ok, SearchResponse.from_rets_response(rets_response)}
    end
  end

  def search(_not_logged_in_rets_client, _search_arguments), do: {:error, :not_logged_in}
end
