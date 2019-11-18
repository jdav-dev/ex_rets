defmodule ExRets.DigestAccessAuthentication.ChallengeTest do
  use ExUnit.Case, async: true

  alias ExRets.DigestAccessAuthentication.Challenge

  doctest Challenge

  @login_uri URI.parse("https://example.com/login")

  describe "parse/1" do
    @tag :unit
    test "handles the example from RFC 2617" do
      challenge = """
      realm="testrealm@host.com",
      qop="auth,auth-int",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      opaque="5ccc069c403ebaf9f0171e9517f40e41"
      """

      assert {:ok,
              %Challenge{
                realm: "testrealm@host.com",
                nonce: "dcd98b7102dd2f0e8b11d0f600bfb0c093",
                opaque: "5ccc069c403ebaf9f0171e9517f40e41",
                qop: [:auth, :auth_int]
              }} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "handles one-line challenges" do
      challenge = ~s/realm="testrealm@host.com",nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"/

      assert {:ok,
              %Challenge{
                realm: "testrealm@host.com",
                nonce: "dcd98b7102dd2f0e8b11d0f600bfb0c093"
              }} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "handles a relative domain URI" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      domain="/search"
      """

      expected_domain = URI.parse("https://example.com/search")

      assert {:ok, %Challenge{domain: [^expected_domain]}} =
               Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "handles multiple domain URIs and maintains order" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      domain="/search /logout"
      """

      expected_domains = [
        URI.parse("https://example.com/search"),
        URI.parse("https://example.com/logout")
      ]

      assert {:ok, %Challenge{domain: ^expected_domains}} = Challenge.parse(challenge, @login_uri)

      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      domain="/logout /search"
      """

      expected_domains = [
        URI.parse("https://example.com/logout"),
        URI.parse("https://example.com/search")
      ]

      assert {:ok, %Challenge{domain: ^expected_domains}} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "handles a full domain URI" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      domain="http://different.example.com/search"
      """

      expected_domain = URI.parse("http://different.example.com/search")

      assert {:ok, %Challenge{domain: [^expected_domain]}} =
               Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "handles stale when stale is true (case-insensitive)" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      stale="true"
      """

      assert {:ok, %Challenge{stale: true}} = Challenge.parse(challenge, @login_uri)

      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      stale="TRUE"
      """

      assert {:ok, %Challenge{stale: true}} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "handles stale when stale is not true" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      stale="false"
      """

      assert {:ok, %Challenge{stale: false}} = Challenge.parse(challenge, @login_uri)

      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      stale="anything other than true"
      """

      assert {:ok, %Challenge{stale: false}} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "handles md5 algorithm" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      algorithm="md5"
      """

      assert {:ok, %Challenge{algorithm: :md5}} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "handles md5-sess algorithm" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      algorithm="md5-sess"
      """

      assert {:ok, %Challenge{algorithm: :md5_sess}} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "maintains qop order" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      qop="auth,auth-int",
      """

      assert {:ok, %Challenge{qop: [:auth, :auth_int]}} = Challenge.parse(challenge, @login_uri)

      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      qop="auth-int,auth",
      """

      assert {:ok, %Challenge{qop: [:auth_int, :auth]}} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "ignores unknown qop values" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      qop="auth,auth-int,invalid",
      """

      assert {:ok, %Challenge{qop: [:auth, :auth_int]}} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "ignores unknown directives" do
      challenge = """
      realm="testrealm@host.com",
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      invalid="invalid"
      """

      assert {:ok, %Challenge{}} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "returns :error for unknown algorithm" do
      challenge = """
      realm="testrealm@host.com"
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"
      algorithm="invalid"
      """

      assert {:error, [~s/unknown algorithm "invalid"/]} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "returns :error tuple for missing realm" do
      challenge = """
      nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"
      """

      assert {:error, ["missing realm"]} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "returns :error tuple for missing nonce" do
      challenge = """
      realm="testrealm@host.com"
      """

      assert {:error, ["missing nonce"]} = Challenge.parse(challenge, @login_uri)
    end

    @tag :unit
    test "returns all error messages at once" do
      challenge = """
      algorithm="invalid"
      """

      assert {:error, [~s/unknown algorithm "invalid"/, "missing realm", "missing nonce"]} =
               Challenge.parse(challenge, @login_uri)
    end
  end
end
