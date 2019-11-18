defmodule ExRets.HttpAuthentication do
  @moduledoc """
  Helper functions to authenticate HTTP requests.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.Credentials
  alias ExRets.DigestAccessAuthentication
  alias ExRets.DigestAccessAuthentication.Response
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @www_authenticate_header "www-authenticate"
  @authorization_header "authorization"

  @doc """
  Updates the headers of a `request` based on a challenge in the `response` headers.

  If multiple `www-authenticate` headers are present, they are tried in order until a supported
  challenge is parsed successfully.

  ## Examples

      iex> request = %ExRets.HttpRequest{uri: URI.parse("https://example.com/login")}
      iex> response = %ExRets.HttpResponse{
      ...>   status: 401,
      ...>   headers: [{"www-authenticate", ~s/Digest realm="testrealm@host.com",nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"/}]
      ...> }
      iex> credentials = %ExRets.Credentials{username: "admin", password: "pass123"}
      iex> ExRets.HttpAuthentication.answer_challenge(request, response, credentials)
      {:ok,
       %ExRets.HttpRequest{
         body: nil,
         method: :get,
         headers: [
           {"authorization",
            "username=\\"admin\\",realm=\\"testrealm@host.com\\",nonce=\\"dcd98b7102dd2f0e8b11d0f600bfb0c093\\",uri=\\"/login\\",response=\\"0528c825042b7eb0c4fca591fe8a6b09\\",algorithm=\\"MD5\\""}
         ],
         uri: %URI{
           authority: "example.com",
           fragment: nil,
           host: "example.com",
           path: "/login",
           port: 443,
           query: nil,
           scheme: "https",
           userinfo: nil
         }
      }}
  """
  @doc since: "0.1.0"
  @spec answer_challenge(HttpRequest.t(), HttpResponse.t(), Credentials.t()) ::
          {:ok, HttpRequest.t()} | {:error, reason :: any()}
  def answer_challenge(
        %HttpRequest{} = request,
        %HttpResponse{headers: response_headers},
        %Credentials{} = credentials
      ) do
    response_headers
    |> find_www_authenticate_headers()
    |> parse_challenges(request.uri)
    |> create_authorization_header(request, credentials)
  end

  defp find_www_authenticate_headers(headers) do
    headers
    |> Enum.reduce([], fn
      {@www_authenticate_header, value}, acc -> [value | acc]
      _, acc -> acc
    end)
    |> Enum.reverse()
  end

  defp parse_challenges([], _request_uri), do: {:error, :challenge_not_found}

  defp parse_challenges([challenge | rest], request_uri) do
    case challenge do
      "Digest" <> challenge -> parse_digest_challenge(challenge, request_uri, rest)
      _ -> parse_challenges(rest, request_uri)
    end
  end

  defp parse_digest_challenge(challenge, request_uri, remaining_challenges) do
    case DigestAccessAuthentication.Challenge.parse(challenge, request_uri) do
      {:ok, challenge} -> {:ok, challenge}
      {:error, _} = error -> try_next_challenge(remaining_challenges, request_uri, error)
    end
  end

  defp try_next_challenge([], _uri, error), do: error
  defp try_next_challenge(challenges, uri, _error), do: parse_challenges(challenges, uri)

  defp create_authorization_header(
         challenge,
         %HttpRequest{} = request,
         %Credentials{} = credentials
       ) do
    case challenge do
      {:ok, %DigestAccessAuthentication.Challenge{} = challenge} ->
        value =
          request
          |> Response.answer_challenge(challenge, credentials)
          |> Response.encode()

        {:ok, set_authorization_header(request, value)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp set_authorization_header(%HttpRequest{headers: headers} = request, value) do
    headers = Enum.reject(headers, fn {header, _} -> header == @authorization_header end)
    headers = [{@authorization_header, value} | headers]
    %HttpRequest{request | headers: headers}
  end
end
