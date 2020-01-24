defmodule ExRets.LoginResponseTest do
  use ExUnit.Case, async: true

  alias ExRets.CapabilityUris
  alias ExRets.HttpClient.Mock
  alias ExRets.HttpRequest
  alias ExRets.LoginResponse
  alias ExRets.RetsResponse
  alias ExRets.SessionInformation

  doctest LoginResponse

  @login_uri URI.parse("https://example.com/login")

  @login_response_body """
  <RETS ReplyCode="0" ReplyText="Operation Successful" IgnoreMe="Please">
    <RETS-RESPONSE>
      Info=USERID;Character;some_agent_id
      Info=USERCLASS;Character;some_user_class
      Info=USERLEVEL;Int;0
      Info=AGENTCODE;Character;some_agent_code
      Info=BROKERCODE;Character;some_broker_code
      Info=BROKERBRANCH;Character;some_broker_branch
      Info=MEMBERNAME;Character;Ms. Agent
      Info=MetadataID;Character;some_metadata_id
      Info=MetadataVersion;Character;1.0.0
      Info=MetadataTimestamp;DateTime;2020-01-23T00:00:00
      Info=MinMetadataTimestamp;DateTime;2020-01-23T00:00:00
      Info=Balance;Character;$5.00
      Info=TimeoutSeconds;Int;3600
      Info=PasswordExpiration;DateTime;2020-02-23T00:00:00
      Info=WarnPasswordExpirationDays;Int;10
      Info=OfficeList;Character;some_broker_code,some_different_broker_code
      Info=StandardNamesVersion;Character;1.1.0
      Info=VendorName;Character;RETS Servers, LLC
      Info=ServerProductName;Character;Generic RETS Server
      Info=ServerProductVersion;Character;1.1.1
      Info=OperatorName;Character;Some MLS
      Info=RoleName;Character;Read-Only
      Info=SupportContactInformation;Character;dev-support@example.com
      Action=/action
      ChangePassword=/change-password
      GetObject=/get-object
      Login=/login
      LoginComplete=/login-complete
      Logout=/logout
      Search=/search
      GetMetadata=/get-metadata
      Update=/update
      PostObject=/post-object
      GetPayloadList=/get-payload-list
    </RETS-RESPONSE>
  </RETS>
  """

  describe "parse/3" do
    setup :open_stream

    @tag :integration
    test "parses a login response from a stream", %{stream: stream} do
      {:ok, rets_response} = LoginResponse.parse(stream, @login_uri, Mock)

      assert %RetsResponse{
               reply_code: 0,
               reply_text: "Operation Successful",
               response: %LoginResponse{
                 session_information: %SessionInformation{
                   user_id: "some_agent_id",
                   user_class: "some_user_class",
                   user_level: 0,
                   agent_code: "some_agent_code",
                   broker_code: "some_broker_code",
                   broker_branch: "some_broker_branch",
                   member_name: "Ms. Agent",
                   metadata_id: "some_metadata_id",
                   metadata_version: "1.0.0",
                   metadata_timestamp: ~N[2020-01-23T00:00:00],
                   min_metadata_timestamp: ~N[2020-01-23T00:00:00],
                   balance: "$5.00",
                   timeout_seconds: 3600,
                   password_expiration: ~N[2020-02-23T00:00:00],
                   warn_password_expiration_days: 10,
                   office_list: ["some_broker_code", "some_different_broker_code"],
                   standard_names_version: "1.1.0",
                   vendor_name: "RETS Servers, LLC",
                   server_product_name: "Generic RETS Server",
                   server_product_version: "1.1.1",
                   operator_name: "Some MLS",
                   role_name: "Read-Only",
                   support_contact_information: "dev-support@example.com"
                 },
                 capability_uris: %CapabilityUris{
                   action: URI.parse("https://example.com/action"),
                   change_password: URI.parse("https://example.com/change-password"),
                   get_object: URI.parse("https://example.com/get-object"),
                   login: URI.parse("https://example.com/login"),
                   login_complete: URI.parse("https://example.com/login-complete"),
                   logout: URI.parse("https://example.com/logout"),
                   search: URI.parse("https://example.com/search"),
                   get_metadata: URI.parse("https://example.com/get-metadata"),
                   update: URI.parse("https://example.com/update"),
                   post_object: URI.parse("https://example.com/post-object"),
                   get_payload_list: URI.parse("https://example.com/get-payload-list")
                 }
               }
             } == rets_response
    end

    @tag :integration
    test "returns errors from the base xml parser" do
      stream = ["<broken>xml"]
      assert {:error, "No more bytes"} = LoginResponse.parse(stream, @login_uri, Mock)
    end
  end

  defp open_stream(_) do
    {:ok, client} = Mock.start_client(:login_response_test)
    request = %HttpRequest{uri: @login_uri}

    stream =
      @login_response_body
      |> to_charlist()
      |> Enum.chunk_every(10)
      |> Enum.map(&to_string/1)

    {:ok, _response, stream} = Mock.open_stream(client, request, stream: stream)
    {:ok, stream: stream}
  end
end
