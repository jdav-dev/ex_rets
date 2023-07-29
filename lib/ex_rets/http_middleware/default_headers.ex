defmodule ExRets.Middleware.DefaultHeaders do
  @moduledoc false
  @moduledoc since: "0.1.0"

  @behaviour ExRets.Middleware

  alias ExRets.Credentials
  alias ExRets.HttpRequest
  alias ExRets.Middleware

  @project_version Keyword.fetch!(Mix.Project.config(), :version)
  @default_user_agent "ExRets/#{@project_version}"

  @impl Middleware
  @doc since: "0.1.0"
  def init(%Credentials{} = credentials) do
    [
      {"user-agent", credentials.user_agent || @default_user_agent},
      {"rets-version", credentials.rets_version},
      {"accept", "*/*"}
    ]
  end

  @impl Middleware
  @doc since: "0.1.0"
  def call(%HttpRequest{headers: headers} = request, next, default_headers)
      when is_list(default_headers) do
    request = %HttpRequest{request | headers: default_headers ++ headers}
    next.(request)
  end
end
