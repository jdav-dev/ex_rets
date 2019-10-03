defmodule ExRets do
  alias ExRets.{Client, Credentials, SearchArguments}

  def new_client(%Credentials{} = credentials) do
    Client.new(credentials)
  end

  def close_client(%Client{} = client) do
    Client.close(client)
  end

  def login(%Client{} = client) do
    Client.login(client)
  end

  def search(%Client{} = client, %SearchArguments{} = search_params) do
    Client.search(client, search_params)
  end
end
