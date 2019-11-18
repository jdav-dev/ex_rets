defmodule ExRets.CompactRecordTest do
  use ExUnit.Case, async: true

  alias ExRets.CompactRecord

  doctest CompactRecord

  describe "decode/2" do
    @tag :unit
    test "handles well-formed compact data with the default delimiter" do
      data = "\tListingKey\tModificationTimestamp\t"
      assert ["ListingKey", "ModificationTimestamp"] == CompactRecord.decode(data)
    end

    @tag :unit
    test "handles well-formed compact data with custom delimiters" do
      data = "\nListingKey\nModificationTimestamp\n"

      assert ["ListingKey", "ModificationTimestamp"] ==
               CompactRecord.decode(data, delimiter: "\n")
    end
  end
end
