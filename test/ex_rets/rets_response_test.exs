defmodule ExRets.RetsResponseTest do
  use ExUnit.Case, async: true

  alias ExRets.RetsResponse

  doctest RetsResponse

  @attributes [
    {[], [], 'ReplyCode', '0'},
    {[], [], 'ReplyText', 'Operation Successful'}
  ]

  describe "read_rets_element_attributes/2" do
    @tag :unit
    test "reads reply_code as an integer" do
      assert %RetsResponse{reply_code: 0} =
               RetsResponse.read_rets_element_attributes(@attributes, %RetsResponse{})
    end

    @tag :unit
    test "reads reply_text as a string" do
      assert %RetsResponse{reply_text: "Operation Successful"} =
               RetsResponse.read_rets_element_attributes(@attributes, %RetsResponse{})
    end
  end
end
