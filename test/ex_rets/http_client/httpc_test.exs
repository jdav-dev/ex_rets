defmodule ExRets.HttpClient.HttpcTest do
  use ExUnit.Case, async: true

  alias ExRets.HttpClient.Httpc
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @moduletag timeout: :timer.seconds(10)

  @test_uri URI.parse("https://www.reso.org")
  @request %HttpRequest{uri: @test_uri}

  describe "start_client/2" do
    @tag :unit
    test "returns a pid" do
      assert {:ok, client} = Httpc.start_client(:httpc_test)
      assert is_pid(client)
    end

    @tag :unit
    test "returns the same client if called again with the same name" do
      assert {:ok, client} = Httpc.start_client(:httpc_test)
      assert {:ok, ^client} = Httpc.start_client(:httpc_test)
    end
  end

  describe "open_stream/3" do
    setup :start_client

    @tag :unit
    test "returns an error if the client process is not alive", %{client: client} do
      Httpc.stop_client(client)
      assert {:error, :http_client_stopped} = Httpc.open_stream(client, @request)
    end

    @tag :reso_dot_org
    test "returns the http response", %{client: client} do
      assert {:ok, %HttpResponse{status: 200}, _stream} = Httpc.open_stream(client, @request)
    end

    @tag :reso_dot_org
    test "returns stream as a pid", %{client: client} do
      {:ok, _response, stream} = Httpc.open_stream(client, @request)
      assert is_pid(stream)
    end

    @tag :reso_dot_org
    test "returns HTTP error responses", %{client: client} do
      uri = URI.parse("https://www.reso.org/thispagedoesnotexist")
      request = %HttpRequest{uri: uri}
      {:ok, %HttpResponse{status: 404}} = Httpc.open_stream(client, request)
    end

    @tag :reso_dot_org
    test "returns httpc errors", %{client: client} do
      uri = URI.parse("https://thisdomaindoesnotexist.nope")
      request = %HttpRequest{uri: uri}
      assert {:error, {:failed_connect, _}} = Httpc.open_stream(client, request)
    end
  end

  describe "stream_next/1" do
    setup [:start_client, :open_stream]

    @tag :reso_dot_org
    test "returns the next part of the HTTP response body", %{stream: stream} do
      {:ok, next, _stream} = Httpc.stream_next(stream)
      assert next =~ "RESO"
    end

    @tag :reso_dot_org
    test "returns an empty string when the stream ends", %{stream: stream} do
      assert {:ok, "", _stream} = stream_recursive(stream)
    end
  end

  describe "close_stream/1" do
    setup [:start_client, :open_stream]

    @tag :reso_dot_org
    test "returns :ok", %{stream: stream} do
      assert :ok = Httpc.close_stream(stream)
    end
  end

  describe "stop_client/1" do
    setup :start_client

    @tag :unit
    test "returns :ok", %{client: client} do
      assert :ok = Httpc.stop_client(client)
    end
  end

  defp start_client(_) do
    {:ok, client} = Httpc.start_client(:httpc_test)

    on_exit(fn ->
      Httpc.stop_client(client)
    end)

    {:ok, client: client}
  end

  defp open_stream(%{client: client}) do
    {:ok, _response, stream} = Httpc.open_stream(client, @request)

    on_exit(fn ->
      Httpc.close_stream(stream)
    end)

    {:ok, stream: stream}
  end

  defp stream_recursive(stream) when is_pid(stream) do
    Httpc.stream_next(stream)
    |> stream_recursive()
  end

  defp stream_recursive({:ok, "", _stream} = result), do: result

  defp stream_recursive({:ok, _next, stream}) do
    Httpc.stream_next(stream)
    |> stream_recursive()
  end

  defp stream_recursive(probably_an_error), do: probably_an_error
end
