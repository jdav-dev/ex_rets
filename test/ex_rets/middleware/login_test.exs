defmodule ExRets.Middleware.LoginTest do
  use ExUnit.Case, async: true

  alias ExRets.Credentials
  alias ExRets.Middleware.Login
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @login_uri URI.parse("https://example.com/login")
  @search_uri URI.parse("https://example.com/search")

  @credentials %Credentials{
    system_id: :test_mls,
    login_uri: @login_uri,
    username: "username",
    password: "password"
  }

  @request %HttpRequest{uri: @search_uri}

  describe "init/1" do
    @tag :unit
    test "accepts credentials and passes them through" do
      assert @credentials == Login.init(@credentials)
    end
  end

  describe "call/3" do
    @tag :unit
    test "calls the login uri for challenge_not_found errors" do
      next = fn
        %HttpRequest{uri: @search_uri, headers: []} -> {:error, :challenge_not_found}
        %HttpRequest{uri: @login_uri} -> throw(:test_passed)
      end

      assert :test_passed == catch_throw(Login.call(@request, next, @credentials))
    end

    @tag :unit
    test "retries the original request after a successful login" do
      {:ok, agent} = Agent.start_link(fn -> 0 end)

      next = fn
        %HttpRequest{uri: @search_uri, headers: []} ->
          case Agent.get(agent, & &1) do
            0 ->
              Agent.update(agent, &(&1 + 1))
              {:error, :challenge_not_found}

            _ ->
              {:ok, %HttpResponse{body: "test passed"}}
          end

        %HttpRequest{uri: @login_uri} ->
          {:ok, %HttpResponse{}}
      end

      assert {:ok, %HttpResponse{body: "test passed"}} == Login.call(@request, next, @credentials)
    end

    @tag :unit
    test "returns errors from failed login attempts" do
      next = fn
        %HttpRequest{uri: @search_uri, headers: []} -> {:error, :challenge_not_found}
        %HttpRequest{uri: @login_uri} -> {:error, :this_is_only_a_test}
      end

      assert {:error, :this_is_only_a_test} == Login.call(@request, next, @credentials)
    end

    @tag :unit
    test "returns :ok responses" do
      next = fn _request ->
        {:ok, %HttpResponse{}}
      end

      assert {:ok, %HttpResponse{}} == Login.call(@request, next, @credentials)
    end

    @tag :unit
    test "returns :ok responses with streams" do
      next = fn _request ->
        {:ok, %HttpResponse{}, :some_stream}
      end

      assert {:ok, %HttpResponse{}, :some_stream} == Login.call(@request, next, @credentials)
    end

    @tag :unit
    test "returns :error responses" do
      next = fn _request ->
        {:error, :reason}
      end

      assert {:error, :reason} == Login.call(@request, next, @credentials)
    end
  end
end
