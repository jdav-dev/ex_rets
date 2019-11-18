defmodule ExRets.CapabilityUrisTest do
  use ExUnit.Case, async: true

  alias ExRets.CapabilityUris

  doctest CapabilityUris

  describe "parse/2" do
    @tag :unit
    test "handles relative paths" do
      key_value_body = """
      Login=/login
      Search=/search
      """

      login_uri = URI.parse("https://example.com/login")

      expected_login_uri = URI.parse("https://example.com/login")
      expected_search_uri = URI.parse("https://example.com/search")

      assert %CapabilityUris{
               login: ^expected_login_uri,
               search: ^expected_search_uri
             } = CapabilityUris.parse(key_value_body, login_uri)
    end

    @tag :unit
    test "handles full URIs" do
      key_value_body = """
      Login=http://different.example.com/login
      Search=http://different.example.com/search
      """

      login_uri = URI.parse("https://example.com/login")

      expected_login_uri = URI.parse("http://different.example.com/login")
      expected_search_uri = URI.parse("http://different.example.com/search")

      assert %CapabilityUris{
               login: ^expected_login_uri,
               search: ^expected_search_uri
             } = CapabilityUris.parse(key_value_body, login_uri)
    end

    @tag :unit
    test "allows spaces around the = delimiter" do
      key_value_body = "Search = /search"
      login_uri = URI.parse("https://example.com/login")
      expected_search_uri = URI.parse("https://example.com/search")

      assert %CapabilityUris{search: ^expected_search_uri} =
               CapabilityUris.parse(key_value_body, login_uri)
    end
  end
end
