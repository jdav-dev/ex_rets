defmodule ExRets.HttpResponse do
  @moduledoc false
  @moduledoc since: "0.1.0"

  defstruct status: 200, headers: [], body: ""

  @type t :: %__MODULE__{
          status: integer(),
          headers: ExRets.HttpAdapter.headers(),
          body: String.t()
        }

  @doc since: "0.1.0"
  def from_httpc({{_, status, _}, headers, body}) do
    headers = Enum.map(headers, fn {key, value} -> {to_string(key), to_string(value)} end)
    body = IO.iodata_to_binary(body)

    %__MODULE__{
      status: status,
      headers: headers,
      body: body
    }
  end
end
