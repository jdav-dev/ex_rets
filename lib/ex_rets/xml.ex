defmodule ExRets.Xml do
  defmacro parse_xml(stream, do: do_block) do
    quote do
      # stream = ["<TEST/>"]
      http_client_implementation = ExRets.HttpClient.Mock

      {:ok, var!(pid, __MODULE__)} = start_agent()
      unquote(do_block)
      {:ok, initial_state} = stop_agent(var!(pid, __MODULE__))

      # opts = [
      #   continuation_fun: &continuation_fun/1,
      #   event_fun: &event_fun/3,
      #   event_state: var!(pid, __MODULE__)
      # ]

      result =
        with {:ok, xml, stream} <- http_client_implementation.stream_next(unquote(stream)) do
          opts = [
            continuation_fun: &continuation_fun/1,
            continuation_state: %{
              stream: stream,
              http_client_implementation: http_client_implementation
            },
            event_fun: &event_fun/3,
            event_state: initial_state
          ]

          # opts = put_continuation_state(opts, stream, http_client_implementation)

          xml
          |> :xmerl_sax_parser.stream(opts)
          |> format_xmerl_result()
        end

      http_client_implementation.close_stream(unquote(stream))
      result
    end
  end

  def start_agent do
    Agent.start_link(fn -> %{acc: %{}, entities: []} end)
  end

  def stop_agent(pid) do
    state = Agent.get(pid, & &1)
    state = %{state | entities: Enum.reverse(state.entities)}

    with :ok <- Agent.stop(pid) do
      {:ok, state}
    end
  end

  def set_root(pid, entity) do
    Agent.update(pid, fn state ->
      state
      |> Map.put(:acc, struct(entity))
      |> Map.update!(:entities, &[{[:acc], entity} | &1])
    end)
  end

  def push_entity(pid, keys, entity) do
    Agent.update(pid, fn state -> Map.update!(state, :entities, &[{keys, entity} | &1]) end)
  end

  # def start_element(pid, name, attributes) do
  #   Agent.update(pid, fn %{entities: [entity | _]} = state ->
  #     :ok = entity.start_element(name, attributes)
  #     state
  #   end)
  # end

  # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/xmerl
  def event_fun({:internalEntityDecl, _, _}, _, _state), do: raise("Entity expansion")
  def event_fun({:externalEntityDecl, _, _, _}, _, _state), do: raise("Entity expansion")

  def event_fun(event, _, %{acc: %{}, entities: [{keys, entity} | rest]} = state) do
    case event do
      {:startElement, _, name, _, attributes} ->
        name = to_string(name)
        attributes = attributes_to_string(attributes)

        case entity.start_element(name, attributes) do
          {:ok, result} ->
            keys = Enum.map(keys, &Access.key/1)

            state
            |> put_in(keys, result)
            |> Map.put(:entities, rest)

          :skip ->
            state
        end

      _ ->
        state
    end
  end

  def event_fun(_event, _, state) do
    state
  end

  defp attributes_to_string(attributes) do
    Enum.map(attributes, fn {_, _, name, value} -> {to_string(name), to_string(value)} end)
  end

  def continuation_fun(%{stream: stream, http_client_implementation: implementation}) do
    case implementation.stream_next(stream) do
      {:ok, xml, stream} -> {xml, %{stream: stream, http_client_implementation: implementation}}
      {:error, reason} -> throw({:error, reason})
    end
  end

  def format_xmerl_result({:ok, %{acc: acc}, _rest}) do
    {:ok, acc}
  end

  def format_xmerl_result({:fatal_error, _location, reason, _end_tags, _event_state}) do
    case reason do
      {:error, reason} -> {:error, reason}
      reason when is_list(reason) -> {:error, to_string(reason)}
      reason when is_binary(reason) -> {:error, reason}
    end
  end

  def format_xmerl_result({:fatal_error, %RuntimeError{message: message}}) do
    {:error, message}
  end

  # defmacro entity(module, do: inner) do
  #   event_fun = __MODULE__.xml_event_fun(module)
  # end

  defmacro root(xml_parser, do: do_block) do
    quote do
      set_root(var!(pid, __MODULE__), unquote(xml_parser))
      unquote(do_block)
    end
  end

  defmacro entity(field, xml_parser) do
    quote do
      push_entity(var!(pid, __MODULE__), [:acc, unquote(field)], unquote(xml_parser))
    end
  end
end
