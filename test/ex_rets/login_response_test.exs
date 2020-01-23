defmodule ExRets.LoginResponseTest do
  use ExUnit.Case, async: true

  alias ExRets.HttpClient.Mock
  alias ExRets.HttpRequest
  alias ExRets.LoginResponse
  alias ExRets.RetsResponse

  doctest LoginResponse

  @login_uri URI.parse("https://example.com/login")

  @login_response_body """
  <RETS ReplyCode="0" ReplyText="Operation Successful" IgnoreThisAttribute="Please">
    <RETS-RESPONSE>
      Key=Value
    </RETS-RESPONSE>
  </RETS>
  """

  describe "parse/3" do
    setup :open_stream

    @tag :integration
    test "parses a login response from a stream", %{stream: stream} do
      assert {:ok, %RetsResponse{response: %LoginResponse{}}} =
               LoginResponse.parse(stream, @login_uri, Mock)
    end

    @tag :integration
    test "returns errors from the base xml parser" do
      stream = ["<broken>xml"]
      assert {:error, "No more bytes"} = LoginResponse.parse(stream, @login_uri, Mock)
    end
  end

  defp open_stream(_) do
    {:ok, client} = Mock.start_client(:login_response_test)
    request = %HttpRequest{uri: @login_uri}

    stream =
      @login_response_body
      |> to_charlist()
      |> Enum.chunk_every(10)
      |> Enum.map(&to_string/1)

    {:ok, _response, stream} = Mock.open_stream(client, request, stream: stream)
    {:ok, stream: stream}
  end
end
