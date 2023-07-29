defmodule ExRets.HttpResponse do
  @moduledoc """
  An HTTP response.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.HttpClient.Httpc

  defstruct status: 200, headers: [], body: ""

  @typedoc "HTTP response"
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          status: status(),
          headers: ExRets.HttpClient.headers(),
          body: body()
        }

  @typedoc "HTTP status code"
  @typedoc since: "0.1.0"
  @type status :: non_neg_integer()

  @typedoc "HTTP response body"
  @typedoc since: "0.1.0"
  @type body :: String.t()

  @doc false
  @doc since: "0.1.0"
  @spec from_httpc(Httpc.result()) :: t()
  def from_httpc({{_, status, _}, headers, body}) when is_integer(status) and status > 0 do
    headers = Enum.map(headers, fn {key, value} -> {to_string(key), to_string(value)} end)
    body = IO.chardata_to_string(body)

    %__MODULE__{
      status: status,
      headers: headers,
      body: body
    }
  end
end
