defmodule ExRets.Middleware do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.RetsClient
  alias ExRets.HttpClient
  alias ExRets.HttpRequest
  alias ExRets.HttpResponse

  @type opts :: any()
  @type next ::
          (HttpRequest.t() ->
             {:ok, HttpResponse.t()}
             | {:ok, HttpResponse.t(), HttpClient.stream()}
             | {:error, reason :: any()})

  @callback init(opts()) :: opts()
  @callback call(HttpRequest.t(), next(), opts()) :: HttpResponse.t()

  def open_stream(
        %RetsClient{
          http_client: http_client,
          http_client_implementation: http_client_implementation,
          http_timeout: timeout,
          middleware: middleware
        },
        %HttpRequest{} = request
      ) do
    open_stream_fun = fn request ->
      http_client_implementation.open_stream(http_client, request, timeout: timeout)
    end

    run =
      middleware
      |> Enum.map(fn
        {module, opts} -> {module, module.init(opts)}
        module -> {module, module.init([])}
      end)
      |> Enum.reverse()
      |> Enum.reduce(open_stream_fun, fn {middleware, opts}, next ->
        fn request -> middleware.call(request, next, opts) end
      end)

    run.(request)
  end
end
