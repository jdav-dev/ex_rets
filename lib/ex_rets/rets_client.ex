defmodule ExRets.RetsClient do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.Credentials
  alias ExRets.HttpClient
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse
  alias ExRets.LoginResponse

  @typedoc since: "0.1.0"
  @type middleware ::
          (HttpRequest.t(), next :: middleware() -> {:ok, HttpResponse.t()} | {:error, any()})

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
  defstruct [
    :credentials,
    :http_client,
    :http_client_implementation,
    :http_timeout,
    :login_response,
    :middleware
  ]
end
