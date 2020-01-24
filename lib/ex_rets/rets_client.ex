defmodule ExRets.RetsClient do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.Credentials
  alias ExRets.HttpClient
  alias ExRets.LoginResponse

  @typedoc since: "0.1.0"
  @type middleware ::
          (Request.t(), next :: middleware() -> {:ok, Response.t()} | {:error, any()})

  @typedoc since: "0.1.0"
  @opaque t :: %__MODULE__{
            credentials: Credentials.t(),
            http_client: HttpClient.client(),
            http_client_implementation: Httpc | Mock,
            http_timeout: non_neg_integer() | :infinity,
            login_response: LoginResponse.t(),
            middleware: [middleware()]
          }

  @derive {Inspect, only: [:credentials]}
  # TODO: Enforce all of these keys
  defstruct [
    :credentials,
    :http_client,
    :http_client_implementation,
    :http_timeout,
    :login_response,
    :middleware
  ]
end
