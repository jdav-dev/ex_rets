defmodule ExRets.MiddlewareTest do
  use ExUnit.Case, async: true

  alias ExRets.CapabilityUris
  alias ExRets.Credentials
  alias ExRets.HttpClient.Mock
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse
  alias ExRets.LoginResponse
  alias ExRets.Middleware
  alias ExRets.RetsClient
  alias ExRets.SessionInformation

  @login_uri URI.parse("https://example.com/login")

  @credentials %Credentials{
    system_id: :test_mls,
    login_uri: @login_uri,
    username: "username",
    password: "password"
  }

  @session_information %SessionInformation{}
  @capability_uris %CapabilityUris{}

  @login_response %LoginResponse{
    session_information: @session_information,
    capability_uris: @capability_uris
  }

  @request %HttpRequest{uri: @login_uri}

  defmodule __MODULE__.MockMiddleware do
    @behaviour Middleware

    @impl Middleware
    def init(opts), do: opts

    @impl Middleware
    def call(%HttpRequest{} = request, next, _opts) do
      response_body = "middleware called"

      case next.(request) do
        {:ok, response, _stream} -> {:ok, %HttpResponse{response | body: response_body}}
        {:ok, response} -> {:ok, %HttpResponse{response | body: response_body}}
        result -> result
      end
    end
  end

  alias __MODULE__.MockMiddleware

  describe "open_stream/2" do
    test "calls middleware" do
      rets_client = %RetsClient{new_rets_client() | middleware: [MockMiddleware]}

      assert {:ok, %HttpResponse{body: "middleware called"}} ==
               Middleware.open_stream(rets_client, @request)
    end

    test "returns ok responses" do
      response = %HttpResponse{}
      rets_client = new_rets_client(response: response, stream: nil)
      assert {:ok, response} == Middleware.open_stream(rets_client, @request)
    end

    test "returns ok responses with streams" do
      response = %HttpResponse{}
      rets_client = new_rets_client(response: response, stream: [])
      assert {:ok, response, []} == Middleware.open_stream(rets_client, @request)
    end
  end

  defp new_rets_client(mock_opts \\ []) do
    {:ok, http_client} = Mock.start_client(:middleware_test, mock_opts)

    %RetsClient{
      credentials: @credentials,
      http_client: http_client,
      http_client_implementation: Mock,
      http_timeout: :infinity,
      login_response: @login_response,
      middleware: []
    }
  end
end
