defmodule ExRets.HttpClient.Httpc do
  @moduledoc false
  @moduledoc since: "0.1.0"

  @behaviour ExRets.HttpClient

  use GenServer, restart: :transient

  alias ExRets.HttpClient
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @typedoc since: "0.1.0"
  @type url :: String.t()

  @typedoc since: "0.1.0"
  @type field :: [byte()]

  @typedoc since: "0.1.0"
  @type value :: String.t()

  @typedoc since: "0.1.0"
  @type header :: {field(), value()}

  @typedoc since: "0.1.0"
  @type headers :: [header()]

  @typedoc since: "0.1.0"
  @type content_type :: String.t()

  @typedoc since: "0.1.0"
  @type body :: String.t()

  @typedoc since: "0.1.0"
  @type request :: {url(), headers()} | {url(), headers(), content_type(), body()}

  @typedoc since: "0.1.0"
  @type http_version() :: charlist()

  @typedoc since: "0.1.0"
  @type status_code :: integer()

  @typedoc since: "0.1.0"
  @type reason_phrase :: charlist()

  @typedoc since: "0.1.0"
  @type status_line :: {http_version(), status_code(), reason_phrase()}

  @typedoc since: "0.1.0"
  @type result :: {status_line(), headers(), body()}

  @error_http_client_stopped {:error, :http_client_stopped}

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
  @spec open_stream(pid, ExRets.HttpRequest.t(), maybe_improper_list) ::
          {:ok, HttpResponse.t(), HttpClient.stream()}
          | {:ok, HttpResponse.t()}
          | {:error, ExRets.reason()}
  def open_stream(client, %HttpRequest{} = request, http_opts \\ [])
      when is_pid(client) and is_list(http_opts) do
    with {:ok, stream} <- GenServer.start_link(__MODULE__, {client, request, http_opts}),
         {:ok, %HttpResponse{status: 200} = response} <-
           GenServer.call(stream, :start_stream, :infinity) do
      {:ok, response, stream}
    else
      false -> {:error, :http_client_stopped}
      error -> error
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
    GenServer.call(stream, :cancel_stream, :infinity)
  catch
    # GenServer doesn't exist
    :exit, _e -> :ok
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
    httpc_request = HttpRequest.to_httpc(request)
    http_opts = merge_default_http_opts(http_opts)

    {:ok, request_id} =
      :httpc.request(request.method, httpc_request, http_opts, httpc_opts(), client)

    {:noreply, %{state | from: from, request_id: request_id}}
  catch
    :exit, _e -> {:stop, :normal, @error_http_client_stopped, state}
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
  catch
    :exit, _e -> {:stop, :normal, @error_http_client_stopped, state}
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
    response = HttpResponse.from_httpc({{~c"HTTP/1.1", 200, ~c"OK"}, headers, ""})
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

  defp merge_default_http_opts(http_opts) do
    preferred_ciphers = ssl_preferred_ciphers()
    ciphers = :ssl.filter_cipher_suites(preferred_ciphers, [])
    versions = ssl_versions()
    preferred_eccs = ssl_preferred_eccs()
    eccs = :ssl.eccs() -- :ssl.eccs() -- preferred_eccs

    default_http_opts = [
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        depth: 3,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ],
        ciphers: ciphers,
        versions: versions,
        eccs: eccs
      ]
    ]

    Keyword.merge(default_http_opts, http_opts)
  end

  defp ssl_preferred_ciphers do
    :ex_rets
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:ssl_preferred_ciphers, [
      # Cipher suites (TLS 1.3): TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:
      # TLS_CHACHA20_POLY1305_SHA256
      %{cipher: :aes_128_gcm, key_exchange: :any, mac: :aead, prf: :sha256},
      %{cipher: :aes_256_gcm, key_exchange: :any, mac: :aead, prf: :sha384},
      %{cipher: :chacha20_poly1305, key_exchange: :any, mac: :aead, prf: :sha256},
      # Cipher suites (TLS 1.2): ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:
      # ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:
      # ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
      %{cipher: :aes_128_gcm, key_exchange: :ecdhe_ecdsa, mac: :aead, prf: :sha256},
      %{cipher: :aes_128_gcm, key_exchange: :ecdhe_rsa, mac: :aead, prf: :sha256},
      %{cipher: :aes_256_gcm, key_exchange: :ecdh_ecdsa, mac: :aead, prf: :sha384},
      %{cipher: :aes_256_gcm, key_exchange: :ecdh_rsa, mac: :aead, prf: :sha384},
      %{cipher: :chacha20_poly1305, key_exchange: :ecdhe_ecdsa, mac: :aead, prf: :sha256},
      %{cipher: :chacha20_poly1305, key_exchange: :ecdhe_rsa, mac: :aead, prf: :sha256},
      %{cipher: :aes_128_gcm, key_exchange: :dhe_rsa, mac: :aead, prf: :sha256},
      %{cipher: :aes_256_gcm, key_exchange: :dhe_rsa, mac: :aead, prf: :sha384}
    ])
  end

  defp ssl_versions do
    :ex_rets
    |> Application.get_env(__MODULE__, [])
    # Protocols: TLS 1.2, TLS 1.3
    |> Keyword.get(:ssl_versions, [:"tlsv1.2", :"tlsv1.3"])
  end

  defp ssl_preferred_eccs do
    :ex_rets
    |> Application.get_env(__MODULE__, [])
    # TLS curves: X25519, prime256v1, secp384r1
    |> Keyword.get(:ssl_preferred_eccs, [:secp256r1, :secp384r1])
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
