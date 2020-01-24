defmodule ExRets.Middleware.LoggerTest do
  use ExUnit.Case, async: true

  alias ExRets.Middleware.Logger, as: LoggerMiddleware
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @request %HttpRequest{uri: URI.parse("https://example.com/login")}

  describe "init/1" do
    @tag :unit
    test "is just a passthrough" do
      assert :test = LoggerMiddleware.init(:test)
      assert 0 = LoggerMiddleware.init(0)
    end
  end

  describe "call/3" do
    @tag :unit
    test "returns :ok responses" do
      next = fn _request ->
        {:ok, %HttpResponse{}}
      end

      assert {:ok, %HttpResponse{}} == LoggerMiddleware.call(@request, next, [])
    end

    @tag :unit
    test "returns :ok responses with streams" do
      next = fn _request ->
        {:ok, %HttpResponse{}, :some_stream}
      end

      assert {:ok, %HttpResponse{}, :some_stream} == LoggerMiddleware.call(@request, next, [])
    end

    @tag :unit
    test "returns :error responses" do
      next = fn _request ->
        {:error, :this_is_only_a_test}
      end

      assert {:error, :this_is_only_a_test} == LoggerMiddleware.call(@request, next, [])
    end
  end
end
