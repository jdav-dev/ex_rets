defmodule ExRets.HttpAdapter do
  alias ExRets.{HttpRequest, HttpResponse}

  @type t :: module()

  @type body :: binary() | nil
  @type client :: any()
  @type header :: {binary(), binary()}
  @type headers :: [{binary(), binary()}]
  @type opts :: Keyword.t()

  @callback new_client(opts()) :: {:ok, client()} | {:error, any()}
  @callback do_request(client(), HttpRequest.t(), opts()) ::
              {:ok, HttpResponse.t()} | {:error, any()}
  @callback close_client(client()) :: :ok | {:error, any()}
end
