defmodule ExRets.HttpResponseTest do
  use ExUnit.Case, async: true

  alias ExRets.HttpResponse

  doctest HttpResponse

  describe "from_httpc/1" do
    test "dumps an :httpc response" do
      httpc_response =
        {{~c"HTTP/1.1", 200, ~c"OK"}, [{~c"cache-control", ~c"private, max-age=0"}],
         ~c"Hello, World!"}

      assert %HttpResponse{
               status: 200,
               headers: [{"cache-control", "private, max-age=0"}],
               body: "Hello, World!"
             } = HttpResponse.from_httpc(httpc_response)
    end
  end
end
