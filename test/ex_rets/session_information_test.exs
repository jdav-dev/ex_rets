defmodule ExRets.SessionInformationTest do
  use ExUnit.Case, async: true

  alias ExRets.SessionInformation

  doctest SessionInformation

  describe "parse/1" do
    @tag :unit
    test "handles character fields" do
      key_value_body = """
      Info=USERID;Character;1
      Info=MetadataVersion;Character;0.0.1
      """

      assert %SessionInformation{user_id: "1", metadata_version: "0.0.1"} =
               SessionInformation.parse(key_value_body)
    end

    @tag :unit
    test "treats fields without types as character fields" do
      key_value_body = """
      Info=USERID;1
      Info=MetadataVersion;0.0.1
      """

      assert %SessionInformation{user_id: "1", metadata_version: "0.0.1"} =
               SessionInformation.parse(key_value_body)
    end

    @tag :unit
    test "handles valid DateTime type values" do
      key_value_body = "Info=MetadataTimestamp;DateTime;2019-11-13T19:58:45"

      assert %SessionInformation{metadata_timestamp: ~N[2019-11-13T19:58:45]} =
               SessionInformation.parse(key_value_body)
    end

    @tag :unit
    test "passes through invalid DateTime type values" do
      key_value_body = "Info=MetadataTimestamp;DateTime;invalid"

      assert %SessionInformation{metadata_timestamp: "invalid"} =
               SessionInformation.parse(key_value_body)
    end

    @tag :unit
    test "handles valid int type values" do
      key_value_body = "Info=TimeoutSeconds;Int;600"
      assert %SessionInformation{timeout_seconds: 600} = SessionInformation.parse(key_value_body)
    end

    @tag :unit
    test "passes through invalid int type values" do
      key_value_body = "Info=TimeoutSeconds;Int;invalid"

      assert %SessionInformation{timeout_seconds: "invalid"} =
               SessionInformation.parse(key_value_body)
    end

    @tag :unit
    test "skips invalid info tokens" do
      key_value_body = "Info=invalid"
      assert %SessionInformation{} = SessionInformation.parse(key_value_body)
    end

    @tag :unit
    test "allows spaces around the = delimiter" do
      key_value_body = "Info = USERID;Character;1"
      assert %SessionInformation{user_id: "1"} = SessionInformation.parse(key_value_body)
    end

    @tag :unit
    test "allows spaces around the ; delimiter" do
      key_value_body = "Info=USERID ; Character ; 1"
      assert %SessionInformation{user_id: "1"} = SessionInformation.parse(key_value_body)
    end
  end
end
