defmodule ExRets.CompactDelimiterTest do
  use ExUnit.Case, async: true

  alias ExRets.CompactDelimiter

  doctest CompactDelimiter

  describe "decode/1" do
    @tag :unit
    test "handles even number length octets" do
      octet = "09"
      assert {:ok, "\t"} == CompactDelimiter.decode(octet)
    end

    @tag :unit
    test "handles odd number length octets" do
      octet = "9"
      assert {:ok, "\t"} == CompactDelimiter.decode(octet)
    end

    @tag :unit
    test "returns :error for invalid octets" do
      octet = "invalid"
      assert :error == CompactDelimiter.decode(octet)
    end
  end
end
