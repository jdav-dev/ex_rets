defmodule ExRets.HttpRequestTest do
  use ExUnit.Case, async: true

  alias ExRets.HttpRequest

  doctest HttpRequest

  describe "to_httpc/1" do
    @tag :unit
    test "dumps :get requests to :httpc request format" do
      request = %HttpRequest{
        method: :get,
        uri: URI.parse("https://example.com/login"),
        headers: [{"authorization", "letmein=please"}]
      }

      assert {'https://example.com/login', [{'authorization', 'letmein=please'}]} =
               HttpRequest.to_httpc(request)
    end

    @tag :unit
    test "dumps :post requests to :httpc request format" do
      request = %HttpRequest{
        method: :post,
        uri: URI.parse("https://example.com/login"),
        headers: [{"authorization", "letmein=please"}, {"content-type", "application/json"}],
        body: ~s/{"letmein":"please"}/
      }

      assert {'https://example.com/login', [{'authorization', 'letmein=please'}],
              'application/json', '{"letmein":"please"}'} = HttpRequest.to_httpc(request)
    end

    @tag :unit
    test "defaults to 'text/plan content type'" do
      request = %HttpRequest{
        method: :post,
        uri: URI.parse("https://example.com/login"),
        body: "pretty please"
      }

      assert {'https://example.com/login', [], 'text/plain', 'pretty please'} =
               HttpRequest.to_httpc(request)
    end
  end
end
