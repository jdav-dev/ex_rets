defmodule ExRets.HttpRequest do
  @type t :: %__MODULE__{
          method: :get | :post,
          uri: URI.t(),
          headers: ExRets.HttpAdapter.headers(),
          body: String.t()
        }

  @enforce_keys [:uri]
  defstruct method: :get, uri: nil, headers: [], body: nil
end
