defmodule ExRets.LogoutResponseTest do
  use ExUnit.Case, async: true

  alias ExRets.HttpClient.Mock
  alias ExRets.HttpRequest
  alias ExRets.LogoutResponse
  alias ExRets.RetsResponse

  doctest LogoutResponse

  @logout_uri URI.parse("https://example.com/logout")

  @login_response_body """
  <RETS ReplyCode="0" ReplyText="Operation Successful" IgnoreMe="Please">
    <RETS-RESPONSE>
      ConnectTime=5
      SignOffMessage=Logged out.
    </RETS-RESPONSE>
  </RETS>
  """

  describe "parse/2" do
    setup :open_stream

    @tag :integration
    test "parses a logout response from a stream", %{stream: stream} do
      {:ok, rets_response} = LogoutResponse.parse(stream, Mock)

      assert %RetsResponse{
               reply_code: 0,
               reply_text: "Operation Successful",
               response: %{
                 "ConnectTime" => "5",
                 "SignOffMessage" => "Logged out."
               }
             } == rets_response
    end

    @tag :integration
    test "returns errors from the base xml parser" do
      stream = ["<broken>xml"]
      assert {:error, "No more bytes"} = LogoutResponse.parse(stream, Mock)
    end

    @tag :integration
    test "returns error if the XML contains entity expansion" do
      # https://en.wikipedia.org/wiki/Billion_laughs_attack
      billion_laughs = [
        """
        <?xml version="1.0"?>
        <!DOCTYPE lolz [
        <!ENTITY lol "lol">
        <!ELEMENT lolz (#PCDATA)>
        <!ENTITY lol1 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
        <!ENTITY lol2 "&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;">
        <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
        <!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
        <!ENTITY lol5 "&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;">
        <!ENTITY lol6 "&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;">
        <!ENTITY lol7 "&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;">
        <!ENTITY lol8 "&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;">
        <!ENTITY lol9 "&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;">
        ]>
        <lolz>&lol9;</lolz>
        """
      ]

      assert {:error, "Entity expansion"} = LogoutResponse.parse(billion_laughs, Mock)
    end
  end

  defp open_stream(_) do
    {:ok, client} = Mock.start_client(:login_response_test)
    request = %HttpRequest{uri: @logout_uri}

    stream =
      @login_response_body
      |> to_charlist()
      |> Enum.chunk_every(10)
      |> Enum.map(&to_string/1)

    {:ok, _response, returned_stream} = Mock.open_stream(client, request, stream: stream)
    {:ok, stream: returned_stream}
  end
end
