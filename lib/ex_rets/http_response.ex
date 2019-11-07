defmodule ExRets.HttpResponse do
  @type t :: %__MODULE__{
          status: integer(),
          headers: ExRets.HttpAdapter.headers(),
          body: String.t()
        }

  @enforce_keys [:status, :headers, :body]
  defstruct status: 200, headers: [], body: ""

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
