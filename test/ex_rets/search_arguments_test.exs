defmodule ExRets.SearchArgumentsTest do
  use ExUnit.Case, async: true

  alias ExRets.SearchArguments

  doctest SearchArguments

  @search_arguments %SearchArguments{
    search_type: "Property",
    class: "Residential",
    count: :include_record_count,
    format: "COMPACT",
    limit: 1000,
    offset: 2000,
    select: "ListingKey",
    standard_names: true
  }

  describe "encode_query/1" do
    test "encodes and escapes search arguments" do
      assert "Class=Residential&Count=1&Format=COMPACT&Limit=1000&Offset=2000&QueryType=DMQL2&SearchType=Property&Select=ListingKey&StandardNames=1" ==
               SearchArguments.encode_query(@search_arguments)
    end
  end
end
