defmodule ExRets do
  alias ExRets.{Client, Credentials, SearchArguments}

  def start_client(%Credentials{} = credentials, opts) do
    Client.start_client(credentials, opts)
  end

  def stop_client(%Client{} = client) do
    Client.stop_client(client)
  end

  def login(%Client{} = client) do
    Client.login(client)
  end

  def search(%Client{} = client, %SearchArguments{} = search_params) do
    Client.search(client, search_params)
  end
end
