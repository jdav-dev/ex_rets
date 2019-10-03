defmodule ExRets.HttpResponse do
  @type t :: %__MODULE__{
          status: integer(),
          headers: ExRets.HttpAdapter.headers(),
          body: binary()
        }

  @enforce_keys [:status, :headers, :body]
  defstruct status: 200, headers: [], body: ""
end
