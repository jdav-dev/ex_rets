defmodule ExRets.DigestAuthentication do
  @type header :: {String.t(), String.t()}
  @type headers :: [header()]

  defmodule Challenge do
    @type t :: %__MODULE__{
            realm: String.t() | nil,
            nonce: String.t() | nil,
            algorithm: String.t() | nil,
            opaque: String.t() | nil,
            qop: String.t() | nil,
            nonce_count: non_neg_integer()
          }

    defstruct realm: nil, nonce: nil, algorithm: nil, opaque: nil, qop: nil, nonce_count: 1
  end

  defmodule Response do
    @type t :: %__MODULE__{
            username: String.t() | nil,
            realm: String.t() | nil,
            nonce: String.t() | nil,
            algorithm: String.t() | nil,
            opaque: String.t() | nil,
            qop: String.t() | nil,
            uri: URI.t() | nil,
            nonce_count: String.t(),
            cnonce: String.t() | nil,
            response: String.t() | nil
          }

    defstruct username: nil,
              realm: nil,
              nonce: nil,
              algorithm: nil,
              opaque: nil,
              qop: nil,
              uri: nil,
              nonce_count: 1,
              cnonce: nil,
              response: nil

    defimpl String.Chars do
      def to_string(response) do
        ~w(
          username="#{response.username}"
          realm="#{response.realm}"
          nonce="#{response.nonce}"
          uri="#{response.uri.path}"
          response="#{response.response}"
        )
        |> maybe_add_qop(response)
        |> maybe_add_algorithm(response)
        |> maybe_add_opaque(response)
        |> Enum.join(", ")
      end

      defp maybe_add_qop(response_list, %{qop: qop} = response) do
        if response.qop && response.qop != "" do
          qop_fields = ~w(
            qop=#{qop}
            nc=#{response.nonce_count}
            cnonce="#{response.cnonce}"
          )

          response_list ++ qop_fields
        else
          response_list
        end
      end

      defp maybe_add_algorithm(response_list, response) do
        if response.algorithm && response.algorithm != "" do
          response_list ++ ~w(algorithm="#{response.algorithm}")
        else
          response_list
        end
      end

      defp maybe_add_opaque(response_list, response) do
        if response.opaque && response.opaque != "" do
          response_list ++ ~w(opaque="#{response.opaque}")
        else
          response_list
        end
      end
    end
  end

  @www_authenticate_header "www-authenticate"
  @digest_regex ~r/^\s*[D|d][I|i][G|g][E|e][S|s][T|t]\s*/

  @spec parse_challenge(headers()) :: Challenge.t()
  def parse_challenge(headers) do
    headers
    |> find_www_authenticate_header()
    |> trim_challenge_string()
    |> new_challenge()
  end

  defp find_www_authenticate_header(headers) do
    Enum.find(headers, {nil, ""}, fn
      {@www_authenticate_header, value} -> Regex.match?(@digest_regex, value)
      _ -> false
    end)
  end

  defp trim_challenge_string({_header, value}) do
    value
    |> String.replace(@digest_regex, "")
    |> String.trim()
  end

  defp new_challenge(challenge_string) do
    challenge_string
    |> parse_directives()
    |> new_challenge_from_directives()
  end

  defp parse_directives(challenge_string) do
    challenge_string
    |> String.split(",")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "=", parts: 2))
    |> Stream.filter(&(length(&1) == 2))
    |> Enum.into(%{}, fn [k, v] -> {k, String.trim(v, "\"")} end)
  end

  defp new_challenge_from_directives(directives) do
    Enum.reduce(directives, %Challenge{}, fn
      {"realm", realm}, challenge -> %Challenge{challenge | realm: realm}
      {"nonce", nonce}, challenge -> %Challenge{challenge | nonce: nonce}
      {"algorithm", algorithm}, challenge -> %Challenge{challenge | algorithm: algorithm}
      {"opaque", opaque}, challenge -> %Challenge{challenge | opaque: opaque}
      {"qop", qop}, challenge -> %Challenge{challenge | qop: qop}
      _, challenge -> challenge
    end)
  end

  def answer_challenge(challenge, username, password, method, uri) do
    cnonce = create_cnonce()
    ha1 = create_ha1(challenge, username, password, cnonce)
    ha2 = create_ha2(method, uri)
    nonce_count_string = format_nonce_count(challenge.nonce_count)
    response = create_response(challenge, ha1, ha2, nonce_count_string, cnonce)

    %Response{
      username: username,
      realm: challenge.realm,
      nonce: challenge.nonce,
      algorithm: challenge.algorithm,
      opaque: challenge.opaque,
      qop: challenge.qop,
      uri: uri,
      nonce_count: nonce_count_string,
      cnonce: cnonce,
      response: response
    }
  end

  defp create_cnonce do
    DateTime.utc_now()
    |> DateTime.to_unix()
    |> to_string()
    |> md5_then_hex()
  end

  defp md5_then_hex(value) do
    :md5
    |> :crypto.hash(value)
    |> Base.encode16()
    |> String.downcase()
  end

  defp create_ha1(challenge, username, password, cnonce) do
    ha1 = md5_then_hex("#{username}:#{challenge.realm}:#{password}")

    case challenge.algorithm && String.downcase(challenge.algorithm) do
      "md5-sess" -> md5_then_hex("#{ha1}:#{challenge.nonce}:#{cnonce}")
      _ -> ha1
    end
  end

  defp create_ha2(method, uri) do
    method = method |> to_string() |> String.upcase()
    md5_then_hex("#{method}:#{uri.path}")
  end

  defp format_nonce_count(nonce_count) do
    nonce_count |> Integer.to_string() |> String.pad_leading(8, "0")
  end

  defp create_response(challenge, ha1, ha2, nc, cnonce) do
    case challenge.qop && String.downcase(challenge.qop) do
      "auth" -> "#{ha1}:#{challenge.nonce}:#{nc}:#{cnonce}:#{challenge.qop}:#{ha2}"
      _ -> "#{ha1}:#{challenge.nonce}:#{ha2}"
    end
    |> md5_then_hex()
  end
end
