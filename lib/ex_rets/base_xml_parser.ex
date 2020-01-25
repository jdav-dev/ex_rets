defmodule ExRets.BaseXmlParser do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias ExRets.HttpClient

  @typedoc since: "0.1.0"
  @type uri :: charlist()

  @typedoc since: "0.1.0"
  @type prefix :: charlist()

  @typedoc since: "0.1.0"
  @type attribute_name :: charlist()

  @typedoc since: "0.1.0"
  @type value :: charlist()

  @typedoc since: "0.1.0"
  @type attributes :: [{uri(), prefix(), attribute_name(), value()}]

  @typedoc since: "0.1.0"
  @type local_name :: charlist()

  @typedoc since: "0.1.0"
  @type qualified_name :: {prefix(), local_name()}

  @typedoc since: "0.1.0"
  @type target :: charlist()

  @typedoc since: "0.1.0"
  @type data :: charlist()

  @typedoc since: "0.1.0"
  @type public_id :: charlist()

  @typedoc since: "0.1.0"
  @type system_id :: charlist()

  @typedoc since: "0.1.0"
  @type name :: charlist()

  @typedoc since: "0.1.0"
  @type model :: charlist()

  @typedoc since: "0.1.0"
  @type element_name :: charlist()

  @typedoc since: "0.1.0"
  @type type :: charlist()

  @typedoc since: "0.1.0"
  @type mode :: charlist()

  @typedoc since: "0.1.0"
  @type n_data :: charlist()

  @typedoc since: "0.1.0"
  @type event ::
          :startDocument
          | :endDocument
          | {:startPrefixMapping, prefix(), uri()}
          | {:endPrefixMapping, prefix()}
          | {:startElement, uri(), local_name(), qualified_name(), attributes()}
          | {:endElement, uri(), local_name(), qualified_name()}
          | {:characters, charlist()}
          | {:ignorableWhitespace, charlist()}
          | {:processingInstruction, target(), data()}
          | {:comment, charlist()}
          | :startCDATA
          | :endCDATA
          | {:startDTD, name(), public_id(), system_id()}
          | :endDTD
          | {:startEntity, system_id()}
          | {:endEntity, system_id()}
          | {:elementDecl, name(), model()}
          | {:attributeDecl, element_name(), attribute_name(), type(), mode(), value()}
          | {:internalEntityDecl, name(), value}
          | {:externalEntityDecl, name(), public_id(), system_id()}
          | {:unparsedEntityDecl, name(), public_id(), system_id(), n_data()}
          | {:notationDecl, name(), public_id(), system_id()}

  @typedoc since: "0.1.0"
  @type current_location :: charlist()

  @typedoc since: "0.1.0"
  @type entity_name :: charlist()

  @typedoc since: "0.1.0"
  @type line_no :: integer

  @typedoc since: "0.1.0"
  @type location :: {current_location, entity_name, line_no}

  @typedoc since: "0.1.0"
  @type state :: any()

  @typedoc since: "0.1.0"
  @type event_fun :: (event(), location(), state() -> state())

  @doc since: "0.1.0"
  @spec parse(HttpClient.stream(), event_fun(), state(), HttpClient.implementation()) ::
          {:ok, state()} | {:error, ExRets.reason()}
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
