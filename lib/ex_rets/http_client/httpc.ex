defmodule ExRets.HttpClient.Httpc do
  @moduledoc false
  @moduledoc since: "0.1.0"

  use GenServer, restart: :transient

  alias ExRets.HttpClient
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @behaviour HttpClient

  @default_http_opts [ssl: [ciphers: :ssl.cipher_suites(:all, :"tlsv1.2")]]

  # Interface

  @impl HttpClient
  @doc since: "0.1.0"
  def start_client(name, opts \\ []) when is_atom(name) and is_list(opts) do
    with {:ok, client} <- maybe_start_httpc(name),
         :ok <- :httpc.set_options([cookies: :enabled], client) do
      {:ok, client}
    end
  end

  defp maybe_start_httpc(name) do
    case :inets.start(:httpc, profile: name) do
      {:error, {:already_started, profile}} -> {:ok, profile}
      result -> result
    end
  end

  @impl HttpClient
  @doc since: "0.1.0"
  def open_stream(client, %HttpRequest{} = request, http_opts \\ [])
      when is_pid(client) and is_list(http_opts) do
    with {:ok, stream} <-
           GenServer.start_link(__MODULE__, {client, request, http_opts}),
         {:ok, %HttpResponse{status: 200} = response} <-
           GenServer.call(stream, :start_stream, :infinity) do
      {:ok, response, stream}
    end
  end

  @impl HttpClient
  @doc since: "0.1.0"
  def stream_next(stream) when is_pid(stream) do
    GenServer.call(stream, :next, :infinity)
  end

  @impl HttpClient
  @doc since: "0.1.0"
  def close_stream(stream) when is_pid(stream) do
    if Process.alive?(stream) do
      GenServer.call(stream, :cancel_stream, :infinity)
    else
      :ok
    end
  end

  @impl HttpClient
  @doc since: "0.1.0"
  def stop_client(client) when is_pid(client) do
    :inets.stop(:httpc, client)
  end

  # Implementation

  @impl GenServer
  @doc false
  def init({client, request, http_opts}) do
    {:ok,
     %{
       client: client,
       from: nil,
       http_opts: http_opts,
       httpc_stream_pid: nil,
       reply_queue: :queue.new(),
       request: request,
       request_id: nil,
       stream_ended: false
     }}
  end

  @impl GenServer
  @doc false
  def handle_call(
        :start_stream,
        from,
        %{client: client, http_opts: http_opts, request: request} = state
      ) do
    {:ok, request_id} = start_async_request(client, request, http_opts)
    {:noreply, %{state | from: from, request_id: request_id}}
  end

  def handle_call(
        :next,
        from,
        %{
          httpc_stream_pid: httpc_stream_pid,
          reply_queue: reply_queue,
          stream_ended: stream_ended
        } = state
      ) do
    cond do
      !:queue.is_empty(reply_queue) ->
        {{:value, queued_reply}, reply_queue} = :queue.out(reply_queue)
        {:reply, queued_reply, %{state | reply_queue: reply_queue}, :hibernate}

      stream_ended ->
        {:reply, {:ok, ""}, state}

      true ->
        :ok = :httpc.stream_next(httpc_stream_pid)
        {:noreply, %{state | from: from}}
    end
  end

  def handle_call(:cancel_stream, _from, %{client: client, request_id: request_id} = state) do
    :ok = :httpc.cancel_request(request_id, client)
    {:stop, :normal, :ok, state}
  end

  @impl GenServer
  @doc false
  def handle_info({:http, {request_id, {:error, reason}}}, %{request_id: request_id} = state) do
    state = send_or_queue_reply({:error, reason}, state)
    {:noreply, state}
  end

  def handle_info({:http, {request_id, result}}, %{from: from, request_id: request_id} = state) do
    response = HttpResponse.from_httpc(result)
    GenServer.reply(from, {:ok, response})
    {:stop, :normal, state}
  end

  def handle_info(
        {:http, {request_id, :stream_start, headers, httpc_stream_pid}},
        %{from: from, request_id: request_id} = state
      ) do
    response = HttpResponse.from_httpc({{'HTTP/1.1', 200, 'OK'}, headers, ''})
    GenServer.reply(from, {:ok, response})
    {:noreply, %{state | from: nil, httpc_stream_pid: httpc_stream_pid}}
  end

  def handle_info({:http, {request_id, :stream, body_part}}, %{request_id: request_id} = state) do
    state = send_or_queue_reply({:ok, body_part, self()}, state)
    {:noreply, state, :hibernate}
  end

  def handle_info({:http, {request_id, :stream_end, _headers}}, %{request_id: request_id} = state) do
    state = send_or_queue_reply({:ok, "", self()}, state)
    {:noreply, %{state | from: nil, stream_ended: true}}
  end

  defp send_or_queue_reply(reply, %{from: nil, reply_queue: reply_queue} = state) do
    %{state | reply_queue: :queue.in(reply, reply_queue)}
  end

  defp send_or_queue_reply(reply, %{from: from, reply_queue: reply_queue} = state) do
    if :queue.is_empty(reply_queue) do
      GenServer.reply(from, reply)
      %{state | from: nil}
    else
      {{:value, queued_reply}, reply_queue} = :queue.out(reply_queue)
      GenServer.reply(from, queued_reply)
      %{state | reply_queue: :queue.in(reply, reply_queue)}
    end
  end

  defp start_async_request(client, %HttpRequest{} = request, http_opts) do
    httpc_request = HttpRequest.to_httpc(request)
    http_opts = merge_default_http_opts(http_opts)

    :httpc.request(request.method, httpc_request, http_opts, httpc_opts(), client)
  end

  defp merge_default_http_opts(http_opts) do
    Keyword.merge(@default_http_opts, http_opts)
  end

  defp httpc_opts do
    [
      sync: false,
      stream: {:self, :once},
      body_format: :binary,
      full_result: true,
      receiver: self()
    ]
  end
end
