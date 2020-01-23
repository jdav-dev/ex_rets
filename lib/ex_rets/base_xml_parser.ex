defmodule ExRets.BaseXmlParser do
  @moduledoc false
  @moduledoc since: "0.1.0"

  @doc since: "0.1.0"
  def parse(stream, event_fun, event_state, http_client_implementation) do
    opts = [
      continuation_fun: &continuation_fun/1,
      event_fun: event_fun,
      event_state: event_state
    ]

    result =
      with {:ok, xml, stream} <- http_client_implementation.stream_next(stream) do
        opts = put_continuation_state(opts, stream, http_client_implementation)

        xml
        |> :xmerl_sax_parser.stream(opts)
        |> format_xmerl_result()
      end

    http_client_implementation.close_stream(stream)
    result
  end

  defp continuation_fun(%{stream: stream, http_client_implementation: implementation}) do
    case implementation.stream_next(stream) do
      {:ok, xml, stream} -> {xml, %{stream: stream, http_client_implementation: implementation}}
      {:error, reason} -> throw({:error, reason})
    end
  end

  defp put_continuation_state(opts, stream, http_client_implementation) do
    continuation_state = %{stream: stream, http_client_implementation: http_client_implementation}
    Keyword.put(opts, :continuation_state, continuation_state)
  end

  defp format_xmerl_result({:ok, event_state, _rest}), do: {:ok, event_state}

  defp format_xmerl_result({:fatal_error, _location, reason, _end_tags, _event_state}) do
    case reason do
      {:error, reason} -> {:error, reason}
      reason when is_list(reason) -> {:error, to_string(reason)}
      reason when is_binary(reason) -> {:error, reason}
    end
  end
end
