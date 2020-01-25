defmodule ExRets.SearchResponseTest do
  use ExUnit.Case, async: true

  alias ExRets.HttpClient.Mock
  alias ExRets.HttpRequest
  alias ExRets.RetsResponse
  alias ExRets.SearchResponse

  doctest SearchResponse

  @search_uri URI.parse("https://example.com/login")

  @search_response_body """
  <RETS ReplyCode="0" ReplyText="Operation Successful" IgnoreThisAttribute="Please">
    <COUNT Records="1" IgnoreThisAttribute="Please" />
    <DELIMITER value="09" IgnoreThisAttribute="Please" />
    <COLUMNS>\tColumn1\tColumn2\t</COLUMNS>
    <DATA>\tData1\tData2\t</DATA>
    <DATA>\t\tData2\t</DATA>
    <MAXROWS />
  </RETS>
  """

  describe "parse/2" do
    setup :open_stream

    @tag :integration
    test "parses a search response from a stream", %{stream: stream} do
      {:ok, rets_response} = SearchResponse.parse(stream, Mock)

      assert %RetsResponse{
               reply_code: 0,
               reply_text: "Operation Successful",
               response: %SearchResponse{
                 count: 1,
                 columns: ["Column1", "Column2"],
                 rows: [
                   ["Data1", "Data2"],
                   ["", "Data2"]
                 ],
                 max_rows: true
               }
             } == rets_response
    end

    @tag :integration
    test "returns errors from the base xml parser" do
      stream = ["<broken>xml"]
      assert {:error, "No more bytes"} = SearchResponse.parse(stream, Mock)
    end

    @tag :integration
    test "returns error if the delimiter cannot be decoded" do
      stream = [
        """
        <RETS ReplyCode="0" ReplyText="Operation Successful">
          <DELIMITER value="invalid" />
        </RETS>
        """
      ]

      assert {:error, "Invalid delimiter"} = SearchResponse.parse(stream, Mock)
    end
  end

  defp open_stream(_) do
    {:ok, client} = Mock.start_client(:search_response_test)
    request = %HttpRequest{uri: @search_uri}

    stream =
      @search_response_body
      |> to_charlist()
      |> Enum.chunk_every(10)
      |> Enum.map(&to_string/1)

    {:ok, _response, returned_stream} = Mock.open_stream(client, request, stream: stream)
    {:ok, stream: returned_stream}
  end
end
