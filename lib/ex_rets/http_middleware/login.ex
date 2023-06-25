defmodule ExRets.Middleware.Login do
  @moduledoc false
  @moduledoc since: "0.1.0"

  @behaviour ExRets.Middleware

  alias ExRets.Credentials
  alias ExRets.HttpRequest
  alias ExRets.Middleware

  @impl Middleware
  @doc since: "0.1.0"
  def init(%Credentials{} = credentials), do: credentials

  @impl Middleware
  @doc since: "0.1.0"
  def call(%HttpRequest{} = request, next, %Credentials{} = credentials) do
    case next.(request) do
      {:error, :challenge_not_found} ->
        login_uri = credentials.login_uri
        login_request = %HttpRequest{uri: login_uri}

        case next.(login_request) do
          {:ok, _response} -> next.(request)
          {:ok, _response, _stream} -> next.(request)
          result -> result
        end

      result ->
        result
    end
  end
end
