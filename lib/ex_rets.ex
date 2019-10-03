defmodule ExRets do
  alias ExRets.DigestAuthentication
  alias ExRets.HttpAdapter.Request

  defmodule Credentials do
    @type t :: %__MODULE__{
            server_uri: URI.t(),
            username: String.t(),
            password: String.t(),
            user_agent: String.t(),
            rets_version: String.t()
          }

    @enforce_keys [:server_uri, :username, :password]
    defstruct server_uri: nil,
              username: nil,
              password: nil,
              user_agent: nil,
              rets_version: "RETS/1.8"
  end

  def login(%Credentials{} = credentials) do
    adapter = ExRets.HttpAdapter.Httpc
    {:ok, client} = adapter.new_client(profile: :crmls)

    request = %Request{
      uri: credentials.server_uri,
      headers: [
        {"user-agent", credentials.user_agent},
        {"rets-version", credentials.rets_version},
        {"accept", "*/*"}
      ]
    }

    {:ok, response} = adapter.do_request(client, request)

    authorization =
      response.headers
      |> DigestAuthentication.parse_challenge()
      |> DigestAuthentication.answer_challenge(
        credentials.username,
        credentials.password,
        request.method,
        request.uri
      )

    request = %Request{
      request
      | headers: [{"authorization", to_string(authorization)} | request.headers]
    }

    {:ok, response} = adapter.do_request(client, request)

    IO.inspect(response, label: :response)

    :ok = adapter.close_client(client)
  end
end
