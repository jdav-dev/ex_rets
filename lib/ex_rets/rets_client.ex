defmodule ExRets.RetsClient do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.Credentials
  alias ExRets.HttpClient
  alias ExRets.HttpClient.Httpc
  alias ExRets.HttpClient.Mock
  alias ExRets.LoginResponse
  alias ExRets.Middleware

  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          credentials: Credentials.t(),
          http_client: HttpClient.client(),
          http_client_implementation: Httpc | Mock,
          http_timeout: non_neg_integer() | :infinity,
          login_response: LoginResponse.t(),
          middleware: [Middleware.t()]
        }

  @derive {Inspect, only: [:credentials]}
  defstruct [
    :credentials,
    :http_client,
    :http_client_implementation,
    :http_timeout,
    :login_response,
    :middleware
  ]
end
