defmodule ExRets.HttpClient do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @typedoc since: "0.1.0"
  @type name :: atom()

  @typedoc since: "0.1.0"
  @type opts :: keyword()

  @typedoc since: "0.1.0"
  @type client :: any()

  @typedoc since: "0.1.0"
  @type stream :: any()

  @typedoc since: "0.1.0"
  @type stream_part :: String.t()

  @typedoc since: "0.1.0"
  @type header :: {binary(), binary()}

  @typedoc since: "0.1.0"
  @type headers :: [header()]

  @typedoc since: "0.1.0"
  @type implementation :: module()

  @callback start_client(name(), opts()) :: {:ok, client()} | {:error, ExRets.reason()}
  @callback open_stream(client(), HttpRequest.t()) ::
              {:ok, HttpResponse.t(), stream()}
              | {:ok, HttpResponse.t()}
              | {:error, ExRets.reason()}
  @callback open_stream(client(), HttpRequest.t(), opts()) ::
              {:ok, HttpResponse.t(), stream()}
              | {:ok, HttpResponse.t()}
              | {:error, ExRets.reason()}
  @callback stream_next(stream()) :: {:ok, stream_part(), stream()} | {:error, ExRets.reason()}
  @callback close_stream(stream()) :: :ok
  @callback stop_client(client()) :: :ok
end
