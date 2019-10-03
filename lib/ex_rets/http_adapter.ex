defmodule ExRets.HttpAdapter do
  @type t :: module()

  @type body :: binary() | nil
  @type client :: any()
  @type header :: {binary(), binary()}
  @type headers :: [{binary(), binary()}]
  @type opts :: Keyword.t()

  defmodule Request do
    @type t :: %__MODULE__{
            method: :get | :post,
            uri: URI.t(),
            headers: ExRets.HttpAdapter.headers(),
            body: binary()
          }

    @enforce_keys [:uri]
    defstruct method: :get, uri: nil, headers: [], body: nil
  end

  defmodule Response do
    @type t :: %__MODULE__{
            status: integer(),
            headers: ExRets.HttpAdapter.headers(),
            body: binary()
          }

    @enforce_keys [:status, :headers, :body]
    defstruct status: 200, headers: [], body: ""
  end

  @callback new_client(opts()) :: {:ok, client()} | {:error, any()}
  @callback do_request(client(), Request.t(), opts()) :: {:ok, Response.t()} | {:error, any()}
  @callback close_client(client()) :: :ok | {:error, any()}
end
