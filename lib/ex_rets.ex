defmodule ExRets do
  alias ExRets.{Client, Credentials}
  alias ExRets.HttpAdapter.Request

  def new_client(%Credentials{} = credentials), do: Client.new(credentials)

  def login(%Client{} = client) do
    request = %Request{uri: client.credentials.login_uri}
    Client.do_request(client, request)
  end
end
