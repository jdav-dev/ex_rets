defmodule ExRets.Middleware.DefaultHeadersTest do
  use ExUnit.Case, async: true

  alias ExRets.Credentials
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse
  alias ExRets.Middleware.DefaultHeaders

  @login_uri URI.parse("https://example.com/login")

  @credentials %Credentials{
    system_id: :test_mls,
    login_uri: @login_uri,
    username: "username",
    password: "password"
  }

  @request %HttpRequest{uri: @login_uri}

  describe "init/1" do
    @tag :unit
    test "accepts credentials and returns a list of default headers" do
      @credentials
      |> DefaultHeaders.init()
      |> Enum.each(fn header ->
        assert {key, value} = header
        assert is_binary(key)
        assert is_binary(value)
      end)
    end
  end

  describe "call/3" do
    @tag :unit
    test "adds default headers to the request" do
      default_header = {"default", "header"}

      next = fn %HttpRequest{headers: headers} ->
        assert default_header in headers
        {:ok, %HttpResponse{}}
      end

      DefaultHeaders.call(@request, next, [default_header])
    end

    @tag :unit
    test "returns :ok responses" do
      next = fn _request ->
        {:ok, %HttpResponse{}}
      end

      assert {:ok, %HttpResponse{}} == DefaultHeaders.call(@request, next, [])
    end

    @tag :unit
    test "returns :ok responses with streams" do
      next = fn _request ->
        {:ok, %HttpResponse{}, :some_stream}
      end

      assert {:ok, %HttpResponse{}, :some_stream} == DefaultHeaders.call(@request, next, [])
    end

    @tag :unit
    test "returns :error responses" do
      next = fn _request ->
        {:error, :reason}
      end

      assert {:error, :reason} == DefaultHeaders.call(@request, next, [])
    end
  end
end
