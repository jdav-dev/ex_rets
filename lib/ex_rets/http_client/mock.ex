defmodule ExRets.HttpClient.Mock do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.HttpClient
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @behaviour HttpClient

  defstruct [:name, :response, :stream]

  @impl HttpClient
  @doc since: "0.1.0"
  def start_client(name, opts \\ []) when is_atom(name) and is_list(opts) do
    response = opts[:response] || %HttpResponse{}
    stream = opts[:stream] || []
    {:ok, %__MODULE__{name: name, response: response, stream: stream}}
  end

  @impl HttpClient
  @doc since: "0.1.0"
  def open_stream(%__MODULE__{response: response, stream: stream}, %HttpRequest{}, opts \\ [])
      when is_list(opts) do
    response = opts[:response] || response
    stream = opts[:stream] || stream
    {:ok, response, stream}
  end

  @impl HttpClient
  @doc since: "0.1.0"
  def stream_next([]), do: {:ok, "", []}
  def stream_next([next | rest]) when is_binary(next), do: {:ok, next, rest}
  def stream_next([reason | _rest]), do: {:error, reason}

  @impl HttpClient
  @doc since: "0.1.0"
  def close_stream(_stream), do: :ok

  @impl HttpClient
  @doc since: "0.1.0"
  def stop_client(%__MODULE__{}), do: :ok
end
