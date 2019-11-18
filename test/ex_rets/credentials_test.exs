defmodule ExRets.CredentialsTest do
  use ExUnit.Case, async: true

  alias ExRets.Credentials

  @credentials %Credentials{
    system_id: :test,
    login_uri: URI.parse("https://example.com/login"),
    username: "admin",
    password: "pass123",
    user_agent: "User-Agent",
    user_agent_password: "pass456",
    rets_version: "RETS/1.8"
  }

  describe "inspect/2" do
    @tag :unit
    test "does not expose username" do
      refute inspect(@credentials) =~ "admin"
    end

    @tag :unit
    test "does not expose password" do
      refute inspect(@credentials) =~ "pass123"
    end

    @tag :unit
    test "does not expose user agent" do
      refute inspect(@credentials) =~ "User-Agent"
    end

    @tag :unit
    test "does not expose user agent password" do
      refute inspect(@credentials) =~ "pass456"
    end
  end
end
