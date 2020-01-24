defmodule ExRets.HttpClient.MockTest do
  use ExUnit.Case, async: true

  alias ExRets.HttpClient.Mock
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  doctest Mock

  describe "start_client/2" do
    @tag :unit
    test "returns a mock client" do
      assert {:ok, %Mock{}} = Mock.start_client(:mock_test)
    end

    @tag :unit
    test "allows setting the response" do
      response = %HttpResponse{body: "test response"}
      assert {:ok, %Mock{response: ^response}} = Mock.start_client(:mock_test, response: response)
    end

    @tag :unit
    test "allows setting the stream" do
      stream = ["test", "stream"]
      assert {:ok, %Mock{stream: ^stream}} = Mock.start_client(:mock_test, stream: stream)
    end
  end

  describe "open_stream/3" do
    setup [:start_client, :create_request]

    @tag :unit
    test "returns the stored response", %{client: client, request: request, response: response} do
      assert {:ok, ^response, _stream} = Mock.open_stream(client, request)
    end

    @tag :unit
    test "returns the stored stream", %{client: client, request: request, stream: stream} do
      assert {:ok, _response, ^stream} = Mock.open_stream(client, request)
    end

    @tag :unit
    test "doesn't return a stream if stream is nil", %{client: client, request: request} do
      assert {:ok, _response} = Mock.open_stream(client, request, stream: nil)
    end

    @tag :unit
    test "allows setting the response", %{client: client, request: request} do
      response = %HttpResponse{body: "different test response"}
      assert {:ok, ^response, _stream} = Mock.open_stream(client, request, response: response)
    end

    @tag :unit
    test "allows setting the stream", %{client: client, request: request} do
      stream = ["different", "test", "stream"]
      assert {:ok, _response, ^stream} = Mock.open_stream(client, request, stream: stream)
    end
  end

  describe "stream_next/1" do
    setup [:start_client, :create_request, :open_stream]

    @tag :unit
    test "returns the next string from the list", %{stream: [next | rest] = stream} do
      assert {:ok, ^next, ^rest} = Mock.stream_next(stream)
    end

    @tag :unit
    test "returns an empty string when the list is empty" do
      stream = []
      assert {:ok, "", []} = Mock.stream_next(stream)
    end

    @tag :unit
    test "returns any non-string as an error" do
      stream = [:connection_timeout]
      assert {:error, :connection_timeout} = Mock.stream_next(stream)
    end
  end

  describe "close_stream/1" do
    setup [:start_client, :create_request, :open_stream]

    @tag :unit
    test "returns :ok", %{stream: stream} do
      assert :ok = Mock.close_stream(stream)
    end
  end

  describe "stop_client/1" do
    setup :start_client

    @tag :unit
    test "returns :ok", %{client: client} do
      assert :ok = Mock.stop_client(client)
    end
  end

  defp start_client(_) do
    response = %HttpResponse{body: "test response"}
    stream = ["test", "stream"]
    {:ok, client} = Mock.start_client(:mock_test, response: response, stream: stream)
    {:ok, client: client, response: response, stream: stream}
  end

  defp create_request(_) do
    uri = URI.parse("https://example.com")
    request = %HttpRequest{uri: uri}
    {:ok, request: request}
  end

  defp open_stream(%{client: client, request: request}) do
    {:ok, _response, stream} = Mock.open_stream(client, request)
    {:ok, stream: stream}
  end
end
