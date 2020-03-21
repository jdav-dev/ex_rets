defmodule ExRets.Xml2 do
  defmacro parse_xml(stream, http_client_implementation, do: do_block) do
    quote do
      {:ok, var!(pid, __MODULE__)} = start_agent()
      unquote(do_block)
      {:ok, initial_state} = stop_agent(var!(pid, __MODULE__))

      result =
        with {:ok, xml, stream} <-
               unquote(http_client_implementation).stream_next(unquote(stream)) do
          opts = [
            {:continuation_fun, &continuation_fun/1},
            {:continuation_state,
             %{
               stream: stream,
               http_client_implementation: unquote(http_client_implementation)
             }},
            {:event_fun, &event_fun/3},
            {:event_state, initial_state},
            :skip_external_dtd
          ]

          xml
          |> :xmerl_sax_parser.stream(opts)
          |> format_xmerl_result()
        end

      unquote(http_client_implementation).close_stream(unquote(stream))
      result
    end
  end

  defmacro root(element_name, initial_acc, do: do_block) do
    quote do
      start_element(var!(pid, __MODULE__), unquote(element_name), unquote(initial_acc))
      unquote(do_block)
      end_element(var!(pid, __MODULE__))
    end
  end

  defmacro attribute(attribute_name, acc_field) do
    quote do
      add_attribute(var!(pid, __MODULE__), unquote(attribute_name), unquote(acc_field), & &1)
    end
  end

  defmacro attribute(attribute_name, acc_field, transform_fun) do
    quote do
      add_attribute(
        var!(pid, __MODULE__),
        unquote(attribute_name),
        unquote(acc_field),
        unquote(transform_fun)
      )
    end
  end

  defmacro element(element_name, do: do_block) do
    quote do
      start_element(var!(pid, __MODULE__), unquote(element_name))
      unquote(do_block)
      end_element(var!(pid, __MODULE__))
    end
  end

  defmacro element(element_name, parent_acc_field, initial_acc, do: do_block) do
    quote do
      start_element(
        var!(pid, __MODULE__),
        unquote(element_name),
        unquote(parent_acc_field),
        unquote(initial_acc)
      )

      unquote(do_block)
      end_element(var!(pid, __MODULE__))
    end
  end

  defmacro text(parent_acc_field) do
    quote do
      add_text(var!(pid, __MODULE__), unquote(parent_acc_field), & &1)
    end
  end

  defmacro text(parent_acc_field, transform_fun) do
    quote do
      add_text(var!(pid, __MODULE__), unquote(parent_acc_field), unquote(transform_fun))
    end
  end

  def start_agent do
    Agent.start_link(fn -> %{current_path: [], elements: %{}} end)
  end

  def start_element(pid, element_name, initial_acc) do
    Agent.update(pid, fn %{current_path: current_path, elements: elements} ->
      current_path = [element_name | current_path]

      elements =
        Map.put(elements, current_path, %{
          attributes: %{},
          initial_acc: initial_acc,
          parent_acc_field: nil,
          text: nil
        })

      %{current_path: current_path, elements: elements}
    end)
  end

  def start_element(pid, element_name) do
    Agent.update(pid, fn %{current_path: current_path, elements: elements} = state ->
      current_path = [element_name | current_path]

      elements =
        Map.put(elements, current_path, %{
          attributes: %{},
          initial_acc: nil,
          parent_acc_field: nil,
          text: nil
        })

      %{state | current_path: current_path, elements: elements}
    end)
  end

  def start_element(pid, element_name, parent_acc_field, initial_acc) do
    Agent.update(pid, fn %{current_path: current_path, elements: elements} ->
      current_path = [element_name | current_path]

      elements =
        Map.put(elements, current_path, %{
          attributes: %{},
          initial_acc: initial_acc,
          parent_acc_field: parent_acc_field,
          text: nil
        })

      %{current_path: current_path, elements: elements}
    end)
  end

  def add_attribute(pid, attribute_name, acc_field, transform_fun) do
    Agent.update(pid, fn %{current_path: current_path, elements: elements} = state ->
      elements =
        update_in(
          elements,
          [current_path, :attributes],
          &Map.put(&1, attribute_name, {acc_field, transform_fun})
        )

      %{state | elements: elements}
    end)
  end

  def add_text(pid, parent_acc_field, transform_fun) do
    Agent.update(pid, fn %{current_path: current_path, elements: elements} = state ->
      elements = put_in(elements, [current_path, :text], {parent_acc_field, transform_fun})
      %{state | elements: elements}
    end)
  end

  def end_element(pid) do
    Agent.update(pid, fn %{current_path: [_ | parent]} = state ->
      %{state | current_path: parent}
    end)
  end

  def stop_agent(pid) do
    state = Agent.get(pid, & &1)
    event_state = %{acc_stack: [], characters: [], current_path: [], elements: state.elements}

    with :ok <- Agent.stop(pid) do
      {:ok, event_state}
    end
  end

  # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/xmerl
  def event_fun({:internalEntityDecl, _, _}, _, _state), do: raise("Entity expansion")
  def event_fun({:externalEntityDecl, _, _, _}, _, _state), do: raise("Entity expansion")

  def event_fun(
        {:startElement, _, name, _, attributes},
        _,
        %{
          acc_stack: acc_stack,
          current_path: current_path,
          elements: elements
        } = state
      ) do
    name = to_string(name)
    current_path = [name | current_path]

    case elements[current_path] do
      %{attributes: element_attributes, initial_acc: initial_acc} when not is_nil(initial_acc) ->
        new_acc = reduce_attributes(attributes, element_attributes, initial_acc)
        %{state | acc_stack: [new_acc | acc_stack], characters: [], current_path: current_path}

      %{attributes: element_attributes, initial_acc: nil} ->
        [current_acc | ancestor_accs] = acc_stack
        current_acc = reduce_attributes(attributes, element_attributes, current_acc)

        %{
          state
          | acc_stack: [current_acc | ancestor_accs],
            characters: [],
            current_path: current_path
        }

      nil ->
        %{state | characters: [], current_path: current_path}
    end
  end

  def event_fun({:characters, characters}, _, state) do
    characters = to_string(characters)
    put_in(state.characters, [characters | state.characters])
  end

  def event_fun(
        {:endElement, _, _name, _},
        _,
        %{
          acc_stack: acc_stack,
          characters: characters,
          current_path: [_element_name | parent_elements] = current_path,
          elements: elements
        } = state
      ) do
    case elements[current_path] do
      %{text: {parent_acc_field, transform_fun}} ->
        [acc | ancestor_accs] = acc_stack

        characters =
          characters
          |> Enum.join("")
          |> transform_fun.()

        acc = Map.put(acc, parent_acc_field, characters)
        %{state | acc_stack: [acc | ancestor_accs], current_path: parent_elements}

      %{parent_acc_field: parent_acc_field} when not is_nil(parent_acc_field) ->
        [acc, parent_acc | ancestor_accs] = acc_stack
        parent_acc = Map.put(parent_acc, parent_acc_field, acc)
        %{state | acc_stack: [parent_acc | ancestor_accs], current_path: parent_elements}

      _ ->
        %{state | current_path: parent_elements}
    end
  end

  def event_fun(_event, _, state) do
    state
  end

  defp reduce_attributes(attributes, element_attributes, acc) do
    attributes
    |> attributes_to_string()
    |> Enum.reduce(acc, fn {name, value}, acc ->
      case Map.fetch(element_attributes, name) do
        {:ok, {acc_field, transform_fun}} -> Map.put(acc, acc_field, transform_fun.(value))
        :error -> acc
      end
    end)
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

  def format_xmerl_result({:ok, %{acc_stack: [result]} = state, _rest}) do
    IO.inspect(state, label: :result_state)

    {:ok, result}
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
end
