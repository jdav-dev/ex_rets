defmodule ExRets.DigestAccessAuthentication.Challenge do
  @moduledoc """
  Digest access authentication challenge as described in RFC 2617 section 3.2.1.
  """
  @moduledoc since: "0.1.0"

  defstruct realm: nil,
            domain: [],
            nonce: nil,
            opaque: nil,
            stale: false,
            algorithm: :md5,
            qop: []

  @typedoc "Digest access authentication challenge as described in RFC 2617 section 3.2.1."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          realm: realm(),
          domain: domain(),
          nonce: nonce(),
          opaque: opaque(),
          stale: stale(),
          algorithm: algorithm(),
          qop: qop_options()
        }

  @typedoc "A string to be displayed to users so they know which username and password to use."
  @typedoc since: "0.1.0"
  @type realm :: String.t()

  @typedoc "A list of `t:URI.t/0` that define the protection space."
  @typedoc since: "0.1.0"
  @type domain :: [URI.t()]

  @typedoc """
  A server-specified data string which should be uniquely generated each time a 401 response is
  made.
  """
  @typedoc since: "0.1.0"
  @type nonce :: String.t()

  @typedoc """
  A string of data, specified by the server, which should be returned by the client unchanged in
  the Authorization header of subsequent requests with URIs in the same protection space.
  """
  @typedoc since: "0.1.0"
  @type opaque :: String.t() | nil

  @typedoc """
  Boolean indicating that the previous request from the client was rejected because the nonce
  value was stale.

  If `true`, the client may wish to simply retry the request with a new encrypted
  response, without reprompting the user for a new username and password.
  """
  @typedoc since: "0.1.0"
  @type stale :: boolean()

  @typedoc "Algorithm used to produce the digest and a checksum."
  @typedoc since: "0.1.0"
  @type algorithm :: :md5 | :md5_sess

  @typedoc """
  List of `t:qop_value/0` indicating the "quality of protection" values supported by the server.
  """
  @typedoc since: "0.1.0"
  @type qop_options :: [qop_value()]

  @typedoc """
  "Quality of protection" value.

  Possible values include:

    * `:auth` - indicates authentication
    * `:auth_sess` - indicates authentication with integrity protection
  """
  @typedoc since: "0.1.0"
  @type qop_value :: :auth | :auth_int

  @doc """
  Parses a digest access authentication `challenge` string.

  Uses `request_uri` to fully qualify any relative paths in the `domain` directive.

  ## Examples

      iex> challenge = \"""
      ...> realm="testrealm@host.com",
      ...> nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
      ...> domain="/search"
      ...> \"""
      iex> request_uri = URI.parse("https://example.com/login")
      iex> ExRets.DigestAccessAuthentication.Challenge.parse(challenge, request_uri)
      {:ok,
        %ExRets.DigestAccessAuthentication.Challenge{
          realm: "testrealm@host.com",
          nonce: "dcd98b7102dd2f0e8b11d0f600bfb0c093",
          domain: [
            %URI{
              host: "example.com",
              path: "/search",
              authority: "example.com",
              port: 443,
              scheme: "https"
            }
          ]
        }
      }

      iex> ExRets.DigestAccessAuthentication.Challenge.parse("", %URI{})
      {:error, ["missing realm", "missing nonce"]}
  """
  @doc since: "0.1.0"
  @spec parse(challenge :: String.t(), request_uri :: URI.t()) ::
          {:ok, t()} | {:error, reasons :: [String.t()]}
  def parse(challenge, %URI{} = request_uri) when is_binary(challenge) do
    challenge
    |> parse_directives()
    |> new_challenge_from_directives(request_uri)
  end

  @directives_regex ~r/(?<directive>\w+)="(?<value>[^"]*)"/

  defp parse_directives(challenge) do
    @directives_regex
    |> Regex.scan(challenge, capture: :all_names)
    |> Enum.into(%{}, fn [k, v] -> {k, String.trim(v)} end)
  end

  defp new_challenge_from_directives(directives, request_uri) do
    directives
    |> Enum.reduce({%__MODULE__{}, []}, &reduce_directives/2)
    |> handle_relative_domain_uris(request_uri)
    |> check_realm()
    |> check_nonce()
    |> return_challenge_or_errors()
  end

  defp reduce_directives({"realm", realm}, {challenge, errors}) do
    {%__MODULE__{challenge | realm: realm}, errors}
  end

  defp reduce_directives({"domain", domain}, {challenge, errors}) do
    parsed_domain =
      domain
      |> String.split()
      |> Enum.map(&URI.parse/1)

    {%__MODULE__{challenge | domain: parsed_domain}, errors}
  end

  defp reduce_directives({"nonce", nonce}, {challenge, errors}) do
    {%__MODULE__{challenge | nonce: nonce}, errors}
  end

  defp reduce_directives({"opaque", opaque}, {challenge, errors}) do
    {%__MODULE__{challenge | opaque: opaque}, errors}
  end

  defp reduce_directives({"stale", stale}, {challenge, errors}) do
    parsed_stale = String.downcase(stale) == "true"
    {%__MODULE__{challenge | stale: parsed_stale}, errors}
  end

  defp reduce_directives({"algorithm", algorithm}, {challenge, errors}) do
    case String.downcase(algorithm) do
      "md5" -> {%__MODULE__{challenge | algorithm: :md5}, errors}
      "md5-sess" -> {%__MODULE__{challenge | algorithm: :md5_sess}, errors}
      _ -> {challenge, [~s/unknown algorithm "#{algorithm}"/ | errors]}
    end
  end

  defp reduce_directives({"qop", qop_options}, {challenge, errors}) do
    parsed_qop_options =
      qop_options
      |> String.split(",")
      |> Enum.reduce([], fn
        "auth", acc -> [:auth | acc]
        "auth-int", acc -> [:auth_int | acc]
        _, acc -> acc
      end)
      |> Enum.reverse()

    {%__MODULE__{challenge | qop: parsed_qop_options}, errors}
  end

  defp reduce_directives(_, challenge_and_errors), do: challenge_and_errors

  defp handle_relative_domain_uris({%__MODULE__{} = challenge, errors}, request_uri) do
    domain =
      Enum.map(challenge.domain, fn
        %URI{host: nil} = domain_uri -> %URI{request_uri | path: domain_uri.path}
        domain_uri -> domain_uri
      end)

    {%__MODULE__{challenge | domain: domain}, errors}
  end

  defp check_realm({%__MODULE__{realm: nil} = challenge, errors}) do
    {challenge, ["missing realm" | errors]}
  end

  defp check_realm(challenge_and_errors), do: challenge_and_errors

  defp check_nonce({%__MODULE__{nonce: nil} = challenge, errors}) do
    {challenge, ["missing nonce" | errors]}
  end

  defp check_nonce(challenge_and_errors), do: challenge_and_errors

  defp return_challenge_or_errors({challenge, errors}) when errors == [] do
    {:ok, challenge}
  end

  defp return_challenge_or_errors({_challenge, errors}) do
    {:error, Enum.reverse(errors)}
  end
end
