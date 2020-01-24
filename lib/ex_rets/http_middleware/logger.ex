defmodule ExRets.Middleware.Logger do
  @moduledoc false
  @moduledoc since: "0.1.0"

  require Logger

  alias ExRets.HttpRequest
  alias ExRets.Middleware

  @behaviour Middleware

  @impl Middleware
  @doc since: "0.1.0"
  def init(opts), do: opts

  @impl Middleware
  @doc since: "0.1.0"
  def call(%HttpRequest{} = request, next, _opts) do
    request_id = generate_request_id()
    Logger.debug("HTTP request:\n#{inspect(request, pretty: true)}", request_id: request_id)
    result = next.(request)

    case result do
      {:ok, response, _stream} ->
        Logger.debug("Begin HTTP response:\n#{inspect(response, pretty: true)}",
          request_id: request_id
        )

      {:ok, response} ->
        Logger.debug("HTTP response:\n#{inspect(response, pretty: true)}", request_id: request_id)

      error ->
        Logger.error("HTTP request failed:\n#{inspect(error, pretty: true)}")
    end

    result
  end

  defp generate_request_id do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    Base.url_encode64(binary)
  end
end
