defmodule ExRets.DigestAccessAuthentication.ResponseTest do
  use ExUnit.Case, async: true

  alias ExRets.Credentials
  alias ExRets.DigestAccessAuthentication.Challenge
  alias ExRets.DigestAccessAuthentication.Response
  alias ExRets.HttpRequest

  doctest Response

  @rfc2617_example %{
    request: %HttpRequest{
      method: :get,
      uri: URI.parse("/dir/index.html")
    },
    challenge: %Challenge{
      realm: "testrealm@host.com",
      nonce: "dcd98b7102dd2f0e8b11d0f600bfb0c093",
      opaque: "5ccc069c403ebaf9f0171e9517f40e41",
      qop: [:auth, :auth_int]
    },
    credentials: %Credentials{
      system_id: :digest_test,
      login_uri: URI.parse("http://www.nowhere.org/dir/login.html"),
      username: "Mufasa",
      password: "Circle Of Life"
    },
    cnonce: "0a4f113b"
  }

  @rfc2617_example_response %Response{
    username: "Mufasa",
    realm: "testrealm@host.com",
    nonce: "dcd98b7102dd2f0e8b11d0f600bfb0c093",
    uri: %URI{path: "/dir/index.html"},
    response: "6629fae49393a05397450978507c4ef1",
    algorithm: :md5,
    cnonce: "0a4f113b",
    opaque: "5ccc069c403ebaf9f0171e9517f40e41",
    qop: :auth,
    nc: 1
  }

  describe "answer_challenge/3" do
    @tag :unit
    test "returns a response" do
      assert %Response{} =
               Response.answer_challenge(
                 @rfc2617_example.request,
                 @rfc2617_example.challenge,
                 @rfc2617_example.credentials
               )
    end
  end

  describe "do_answer_challenge/4" do
    @tag :unit
    test "handles the example from RFC 2617" do
      assert @rfc2617_example_response ==
               Response.do_answer_challenge(
                 @rfc2617_example.request,
                 @rfc2617_example.challenge,
                 @rfc2617_example.credentials,
                 @rfc2617_example.cnonce
               )
    end

    @tag :unit
    test "handles :auth_int qop" do
      request = %HttpRequest{@rfc2617_example.request | method: :post, body: "HELLO"}
      challenge = %Challenge{@rfc2617_example.challenge | qop: [:auth_int]}

      assert %Response{response: "e353d1a16929b23cd68a5b73409c6bd7", qop: :auth_int} =
               Response.do_answer_challenge(
                 request,
                 challenge,
                 @rfc2617_example.credentials,
                 @rfc2617_example.cnonce
               )
    end

    @tag :unit
    test "handles nil request body in HA2 if qop is :auth_int" do
      request = %HttpRequest{@rfc2617_example.request | method: :post, body: nil}
      challenge = %Challenge{@rfc2617_example.challenge | qop: [:auth_int]}

      assert %Response{response: "4bb0e26e65bdae3e89570d68fd7a073b", qop: :auth_int} =
               Response.do_answer_challenge(
                 request,
                 challenge,
                 @rfc2617_example.credentials,
                 @rfc2617_example.cnonce
               )
    end

    @tag :unit
    test "handles empty qop" do
      challenge = %Challenge{@rfc2617_example.challenge | qop: []}

      assert %Response{response: "670fd8c2df070c60b045671b8b24ff02", qop: nil} =
               Response.do_answer_challenge(
                 @rfc2617_example.request,
                 challenge,
                 @rfc2617_example.credentials,
                 @rfc2617_example.cnonce
               )
    end

    @tag :unit
    test "handles :md5_sess algorithm" do
      challenge = %Challenge{@rfc2617_example.challenge | algorithm: :md5_sess}

      assert %Response{response: "8e3825c57e897f5a0dec6c2d4e5059d0", algorithm: :md5_sess} =
               Response.do_answer_challenge(
                 @rfc2617_example.request,
                 challenge,
                 @rfc2617_example.credentials,
                 @rfc2617_example.cnonce
               )
    end
  end

  describe "encode/1" do
    @tag :unit
    test "correctly formats the example from RFC 2617" do
      assert Response.encode(@rfc2617_example_response) ==
               ~s|username="Mufasa",realm="testrealm@host.com",nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",uri="/dir/index.html",response="6629fae49393a05397450978507c4ef1",algorithm="MD5",opaque="5ccc069c403ebaf9f0171e9517f40e41",cnonce="0a4f113b",qop="auth",nc=00000001|
    end

    @tag :unit
    test "formats :md5 algorithm correctly" do
      response = %Response{@rfc2617_example_response | algorithm: :md5}
      assert Response.encode(response) =~ ~s/algorithm="MD5"/
    end

    @tag :unit
    test "formats :auth qop correctly" do
      response = %Response{@rfc2617_example_response | qop: :auth}
      assert Response.encode(response) =~ ~s/qop="auth"/
    end

    @tag :unit
    test "formats :auth_int qop correctly" do
      response = %Response{@rfc2617_example_response | qop: :auth_int}
      assert Response.encode(response) =~ ~s/qop="auth-int"/
    end

    @tag :unit
    test "formats MD5-sess algorithm correctly" do
      response = %Response{@rfc2617_example_response | algorithm: :md5_sess}
      assert Response.encode(response) =~ ~s/algorithm="MD5-sess"/
    end

    @tag :unit
    test "does not include opaque if opaque is nil" do
      response = %Response{@rfc2617_example_response | opaque: nil}
      refute Response.encode(response) =~ "opaque="
    end

    @tag :unit
    test "does not include cnonce if qop is nil" do
      response = %Response{@rfc2617_example_response | qop: nil}
      refute Response.encode(response) =~ "cnonce="
    end

    @tag :unit
    test "does not include qop if qop is nil" do
      response = %Response{@rfc2617_example_response | qop: nil}
      refute Response.encode(response) =~ "qop="
    end

    @tag :unit
    test "does not include nc if qop is nil" do
      response = %Response{@rfc2617_example_response | qop: nil}
      refute Response.encode(response) =~ "nc="
    end
  end
end
