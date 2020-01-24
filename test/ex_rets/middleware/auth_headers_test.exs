defmodule ExRets.Middleware.AuthHeadersTest do
  use ExUnit.Case, async: true

  alias ExRets.Credentials
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse
  alias ExRets.Middleware.AuthHeaders

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
    test "accepts credentials and passes them through" do
      assert @credentials == AuthHeaders.init(@credentials)
    end
  end

  describe "call/3" do
    @tag :integration

    test "adds an authorization header after a 401 response" do
      next = fn
        %HttpRequest{headers: [{"authorization", _}]} ->
          {:ok, %HttpResponse{}}

        _request ->
          {:ok,
           %HttpResponse{
             status: 401,
             headers: [
               {"www-authenticate",
                ~s/Digest realm="testrealm@host.com",nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"/}
             ]
           }}
      end

      assert {:ok, %HttpResponse{}} == AuthHeaders.call(@request, next, @credentials)
    end

    test "does not add an authorization header after a 200 response" do
      next = fn
        %HttpRequest{headers: [{"authorization", _}]} ->
          flunk("Should not have added authorization header")

        _request ->
          {:ok, %HttpResponse{}}
      end

      assert {:ok, %HttpResponse{}} == AuthHeaders.call(@request, next, @credentials)
    end

    @tag :unit
    test "returns :ok responses" do
      next = fn _request ->
        {:ok, %HttpResponse{}}
      end

      assert {:ok, %HttpResponse{}} == AuthHeaders.call(@request, next, @credentials)
    end

    @tag :unit
    test "returns :ok responses with streams" do
      next = fn _request ->
        {:ok, %HttpResponse{}, :some_stream}
      end

      assert {:ok, %HttpResponse{}, :some_stream} ==
               AuthHeaders.call(@request, next, @credentials)
    end

    @tag :unit
    test "returns :error responses" do
      next = fn _request ->
        {:error, :reason}
      end

      assert {:error, :reason} == AuthHeaders.call(@request, next, @credentials)
    end
  end
end
