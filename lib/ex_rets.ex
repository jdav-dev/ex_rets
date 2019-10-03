defmodule ExRets do
  alias ExRets.{Client, Credentials, HttpRequest, HttpResponse}

  def new_client(%Credentials{} = credentials) do
    Client.new(credentials)
  end

  def close_client(%Client{} = client) do
    Client.close(client)
  end

  def login(%Client{} = client) do
    request = %HttpRequest{uri: client.credentials.login_uri}

    with {:ok, %HttpResponse{body: body}} <- Client.do_request(client, request) do
      parse_capability(body)
    end
  end

  defp parse_capability(body) do
    body
  end
end
