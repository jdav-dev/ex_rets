defmodule ExRets.DigestAccessAuthentication.Response do
  @moduledoc """
  Digest access authentication response as described in RFC 2617 section 3.2.2.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.Credentials
  alias ExRets.DigestAccessAuthentication.Challenge
  alias ExRets.HttpRequest

  defstruct username: nil,
            realm: nil,
            nonce: nil,
            uri: nil,
            response: nil,
            algorithm: :md5,
            cnonce: nil,
            opaque: nil,
            qop: nil,
            nc: 1

  @typedoc "Digest access authentication response as described in RFC 2617 section 3.2.2."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          username: username(),
          realm: Challenge.realm(),
          nonce: Challenge.nonce(),
          uri: uri(),
          response: response(),
          algorithm: Challenge.algorithm(),
          cnonce: cnonce(),
          opaque: Challenge.opaque(),
          qop: Challenge.qop_value(),
          nc: nonce_count()
        }

  @typedoc "The user's name in the specified realm."
  @typedoc since: "0.1.0"
  @type username :: String.t()

  @typedoc """
  The URI that the digest access authentication response is being sent to.
  """
  @typedoc since: "0.1.0"
  @type uri :: URI.t()

  @typedoc "A computed string of 32 hex digits which proves that the user knows a password."
  @typedoc since: "0.1.0"
  @type response :: String.t()

  @typedoc """
  This MUST be specified if a qop directive is sent, and MUST NOT be specified if the server did
  not send a qop directive in the `www-authenticate` header field.  The cnonce-value is an opaque
  string value provided by the client and used by both client and server to avoid chosen plaintext
  attacks, to provide mutual authentication, and to provide some message integrity protection.
  """
  @typedoc since: "0.1.0"
  @type cnonce :: String.t()

  @typedoc """
  This MUST be specified if a qop directive is sent, and MUST NOT be specified if the server did
  not send a qop directive in the WWW-Authenticate header field.  The nc-value is the hexadecimal
  count of the number of requests (including the current request) that the client has sent with
  the nonce value in this request.  For example, in the first request sent in response to a given
  nonce value, the client sends "nc=00000001".  The purpose of this directive is to allow the
  server to detect request replays by maintaining its own copy of this count - if the same
  nc-value is seen twice, then the request is a replay.
  """
  @typedoc since: "0.1.0"
  @type nonce_count :: non_neg_integer()

  @doc """
  Derives a digest access authentication `response`.
  """
  @doc since: "0.1.0"
  @spec answer_challenge(HttpRequest.t(), Challenge.t(), Credentials.t()) :: response :: t()
  def answer_challenge(
        %HttpRequest{} = request,
        %Challenge{} = challenge,
        %Credentials{} = credentials
      ) do
    cnonce = create_cnonce()
    do_answer_challenge(request, challenge, credentials, cnonce)
  end

  defp create_cnonce do
    16
    |> :crypto.strong_rand_bytes()
    |> Base.encode16()
    |> String.downcase()
  end

  @doc false
  # Accepting `cnonce` as input here for testing purposes.
  def do_answer_challenge(
        %HttpRequest{} = request,
        %Challenge{} = challenge,
        %Credentials{} = credentials,
        cnonce
      ) do
    response =
      %__MODULE__{
        username: credentials.username,
        realm: challenge.realm,
        nonce: challenge.nonce,
        uri: request.uri,
        algorithm: challenge.algorithm,
        cnonce: cnonce,
        opaque: challenge.opaque
      }
      |> pick_qop(challenge)

    ha1 = create_ha1(response, credentials.password)
    ha2 = create_ha2(request, response)
    set_response(response, ha1, ha2)
  end

  defp pick_qop(response, %Challenge{qop: qop}) do
    cond do
      :auth in qop -> %__MODULE__{response | qop: :auth}
      :auth_int in qop -> %__MODULE__{response | qop: :auth_int}
      true -> response
    end
  end

  defp create_ha1(response, password) do
    md5_ha1 = md5_then_hex("#{response.username}:#{response.realm}:#{password}")

    case response.algorithm do
      :md5 -> md5_ha1
      :md5_sess -> md5_then_hex("#{md5_ha1}:#{response.nonce}:#{response.cnonce}")
    end
  end

  defp md5_then_hex(value) do
    :md5
    |> :crypto.hash(value)
    |> Base.encode16()
    |> String.downcase()
  end

  defp create_ha2(request, %__MODULE__{qop: qop}) do
    uppercase_method =
      request.method
      |> to_string()
      |> String.upcase()

    if qop == :auth_int do
      md5_then_hex("#{uppercase_method}:#{request.uri.path}:#{md5_then_hex(request.body || "")}")
    else
      md5_then_hex("#{uppercase_method}:#{request.uri.path}")
    end
  end

  defp set_response(response, ha1, ha2) do
    case response.qop do
      :auth ->
        %__MODULE__{
          response
          | qop: :auth,
            response:
              md5_then_hex(
                "#{ha1}:#{response.nonce}:#{format_nonce_count(response.nc)}:#{response.cnonce}:#{
                  qop_value_to_string(:auth)
                }:#{ha2}"
              )
        }

      :auth_int ->
        %__MODULE__{
          response
          | qop: :auth_int,
            response:
              md5_then_hex(
                "#{ha1}:#{response.nonce}:#{format_nonce_count(response.nc)}:#{response.cnonce}:#{
                  qop_value_to_string(:auth_int)
                }:#{ha2}"
              )
        }

      _ ->
        %__MODULE__{response | response: md5_then_hex("#{ha1}:#{response.nonce}:#{ha2}")}
    end
  end

  defp format_nonce_count(nonce_count) do
    nonce_count
    |> Integer.to_string()
    |> String.pad_leading(8, "0")
  end

  defp qop_value_to_string(:auth), do: "auth"
  defp qop_value_to_string(:auth_int), do: "auth-int"

  @doc """
  Encodes a digest access authentication `response` as a string that can be used in an
  Authorization header.

  ## Examples

      iex> response = %ExRets.DigestAccessAuthentication.Response{
      ...>   username: "Mufasa",
      ...>   realm: "testrealm@host.com",
      ...>   nonce: "dcd98b7102dd2f0e8b11d0f600bfb0c093",
      ...>   uri: %URI{path: "/dir/index.html"},
      ...>   response: "6629fae49393a05397450978507c4ef1",
      ...>   algorithm: :md5,
      ...>   cnonce: "0a4f113b",
      ...>   opaque: "5ccc069c403ebaf9f0171e9517f40e41",
      ...>   qop: :auth,
      ...>   nc: 1
      ...> }
      iex> ExRets.DigestAccessAuthentication.Response.encode(response)
      "username=\\"Mufasa\\",realm=\\"testrealm@host.com\\",nonce=\\"dcd98b7102dd2f0e8b11d0f600bfb0c093\\",uri=\\"/dir/index.html\\",response=\\"6629fae49393a05397450978507c4ef1\\",algorithm=\\"MD5\\",opaque=\\"5ccc069c403ebaf9f0171e9517f40e41\\",cnonce=\\"0a4f113b\\",qop=\\"auth\\",nc=00000001"
  """
  @doc since: "0.1.0"
  @spec encode(response :: t()) :: String.t()
  def encode(%__MODULE__{} = response) do
    ~w(
      algorithm="#{algorithm_to_string(response.algorithm)}"
      response="#{response.response}"
      uri="#{response.uri.path}"
      nonce="#{response.nonce}"
      realm="#{response.realm}"
      username="#{response.username}"
    )
    |> maybe_add_opaque(response)
    |> maybe_add_qop_fields(response)
    |> Enum.reverse()
    |> Enum.join(",")
  end

  defp algorithm_to_string(:md5), do: "MD5"
  defp algorithm_to_string(:md5_sess), do: "MD5-sess"

  defp maybe_add_opaque(response_list, %__MODULE__{opaque: opaque}) do
    case opaque do
      nil -> response_list
      _ -> [~s/opaque="#{opaque}"/ | response_list]
    end
  end

  defp maybe_add_qop_fields(response_list, %__MODULE__{cnonce: cnonce, qop: qop, nc: nc}) do
    if qop do
      qop_fields = ~w(
          nc=#{format_nonce_count(nc)}
          qop="#{qop_value_to_string(qop)}"
          cnonce="#{cnonce}"
        )

      qop_fields ++ response_list
    else
      response_list
    end
  end
end
