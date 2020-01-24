defmodule ExRets.Middleware.AuthHeaders do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.Credentials
  alias ExRets.HttpAuthentication
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse
  alias ExRets.Middleware

  @behaviour Middleware

  @impl Middleware
  @doc since: "0.1.0"
  def init(%Credentials{} = credentials), do: credentials

  @impl Middleware
  @doc since: "0.1.0"
  def call(%HttpRequest{} = request, next, %Credentials{} = credentials) do
    with {:ok, %HttpResponse{status: 401} = response} <- next.(request),
         {:ok, request_with_auth} <-
           HttpAuthentication.answer_challenge(request, response, credentials) do
      next.(request_with_auth)
    end
  end
end
