defmodule ExRets.HttpAuthenticationTest do
  use ExUnit.Case, async: true

  alias ExRets.Credentials
  alias ExRets.HttpAuthentication
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  doctest HttpAuthentication

  @request %HttpRequest{
    uri: URI.parse("https://example.com/login")
  }

  @digest_response %HttpResponse{
    status: 401,
    headers: [
      {"www-authenticate",
       """
       Digest realm="testrealm@host.com",
       qop="auth,auth-int",
       nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
       opaque="5ccc069c403ebaf9f0171e9517f40e41"
       """}
    ]
  }

  @credentials %Credentials{
    username: "admin",
    password: "pass123"
  }

  describe "answer_challenge/3" do
    test "returns a header for a valid digest challenge" do
      assert {:ok, %HttpRequest{}} =
               HttpAuthentication.answer_challenge(@request, @digest_response, @credentials)
    end

    test "returns {:error, :challenge_not_found} if no supported challenges are found" do
      response = %HttpResponse{status: 401, headers: [{"unrelated", "ignore me"}]}

      assert {:error, :challenge_not_found} =
               HttpAuthentication.answer_challenge(@request, response, @credentials)
    end

    test "skips unknown challenges" do
      response = %HttpResponse{
        status: 401,
        headers: [
          {"www-authenticate", "Invalid challenge=accepted"},
          {"www-authenticate",
           """
           Digest realm="testrealm@host.com",
           qop="auth,auth-int",
           nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
           opaque="5ccc069c403ebaf9f0171e9517f40e41"
           """}
        ]
      }

      assert {:ok, %HttpRequest{}} =
               HttpAuthentication.answer_challenge(@request, response, @credentials)
    end

    test "skips challenges that fail to parse" do
      response = %HttpResponse{
        status: 401,
        headers: [
          {"www-authenticate", "Digest invalid=true"},
          {"www-authenticate",
           """
           Digest realm="testrealm@host.com",
           qop="auth,auth-int",
           nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
           opaque="5ccc069c403ebaf9f0171e9517f40e41"
           """}
        ]
      }

      assert {:ok, %HttpRequest{}} =
               HttpAuthentication.answer_challenge(@request, response, @credentials)
    end

    test "returns the last error if no valid challenge was found" do
      response = %HttpResponse{
        status: 401,
        headers: [{"www-authenticate", "Digest invalid=true"}]
      }

      assert {:error, ["missing realm", "missing nonce"]} =
               HttpAuthentication.answer_challenge(@request, response, @credentials)
    end
  end
end
