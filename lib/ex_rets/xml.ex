defmodule ExRets.Xml do
  def parse(schema, stream, http_client_implementation) do
    result =
      with {:ok, xml, stream} <- http_client_implementation.stream_next(stream) do
        opts = [
          {:continuation_fun, &continuation_fun/1},
          {:continuation_state,
           %{
             stream: stream,
             http_client_implementation: http_client_implementation
           }},
          {:event_fun, &event_fun/3},
          {:event_state, schema},
          :skip_external_dtd
        ]

        xml
        |> :xmerl_sax_parser.stream(opts)
        |> format_xmerl_result()
      end

    http_client_implementation.close_stream(stream)
    result
  end

  # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/xmerl
  defp event_fun({:internalEntityDecl, _, _}, _, _state), do: raise("Entity expansion")
  defp event_fun({:externalEntityDecl, _, _, _}, _, _state), do: raise("Entity expansion")

  defp event_fun(
         {:startElement, _, name, _, attributes},
         _,
         %{
           acc_stack: acc_stack,
           current_path: current_path,
           elements: elements
         } = state
       ) do
    current_path = [name | current_path]

    case elements[current_path] do
      nil ->
        %{state | characters: [], current_path: current_path}

      %{attributes: element_attributes, initial_acc: nil} ->
        [current_acc | ancestor_accs] = acc_stack
        current_acc = reduce_attributes(attributes, element_attributes, current_acc)

        %{
          state
          | acc_stack: [current_acc | ancestor_accs],
            characters: [],
            current_path: current_path
        }

      %{attributes: element_attributes, initial_acc: %{} = initial_acc} ->
        new_acc = reduce_attributes(attributes, element_attributes, initial_acc)
        %{state | acc_stack: [new_acc | acc_stack], characters: [], current_path: current_path}
    end
  end

  defp event_fun({:characters, characters}, _, state) do
    put_in(state.characters, [characters | state.characters])
  end

  defp event_fun(
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
      %{list?: list?, parent_acc_field: parent_acc_field, text: text_opts} ->
        updated_acc_stack =
          acc_stack
          |> maybe_put_characters(characters, text_opts)
          |> maybe_reduce_acc_to_parent(parent_acc_field, list?)

        %{state | acc_stack: updated_acc_stack, current_path: parent_elements}

      nil ->
        %{state | current_path: parent_elements}
    end
  end

  defp event_fun(_event, _, state) do
    state
  end

  defp continuation_fun(%{stream: stream, http_client_implementation: implementation}) do
    case implementation.stream_next(stream) do
      {:ok, xml, stream} -> {xml, %{stream: stream, http_client_implementation: implementation}}
      {:error, reason} -> throw({:error, reason})
    end
  end

  defp format_xmerl_result({:ok, %{acc_stack: [result]}, _rest}) do
    {:ok, result}
  end

  defp format_xmerl_result({:fatal_error, _location, reason, _end_tags, _event_state}) do
    case reason do
      {:error, reason} -> {:error, reason}
      reason when is_list(reason) -> {:error, to_string(reason)}
      reason when is_binary(reason) -> {:error, reason}
    end
  end

  defp format_xmerl_result({:fatal_error, %RuntimeError{message: message}}) do
    {:error, message}
  end

  defp reduce_attributes(attributes, element_attributes, acc) do
    attributes
    |> attributes_to_string()
    |> Enum.reduce(acc, fn {name, value}, acc ->
      case Map.fetch(element_attributes, name) do
        {:ok, {acc_field, transform_fun}} ->
          value = transform_fun.(value)
          Map.put(acc, acc_field, value)

        :error ->
          acc
      end
    end)
  end

  defp attributes_to_string(attributes) do
    Enum.map(attributes, fn {_, _, name, value} -> {to_string(name), to_string(value)} end)
  end

  defp maybe_put_characters(acc_stack, characters, text_opts) do
    case text_opts do
      nil ->
        acc_stack

      {acc_field, transform_fun} ->
        [acc | ancestor_accs] = acc_stack

        transformed_characters =
          characters
          |> Enum.map(&to_string/1)
          |> Enum.join("")
          |> transform_fun.()

        updated_acc = Map.put(acc, acc_field, transformed_characters)
        [updated_acc | ancestor_accs]
    end
  end

  defp maybe_reduce_acc_to_parent(acc_stack, parent_acc_field, list?) do
    case parent_acc_field do
      nil ->
        acc_stack

      parent_acc_field ->
        [acc, parent_acc | ancestor_accs] = acc_stack

        updated_acc =
          case list? do
            # credo:disable-for-next-line
            true -> Map.update!(parent_acc, parent_acc_field, &(&1 ++ [acc]))
            false -> Map.put(parent_acc, parent_acc_field, acc)
          end

        [updated_acc | ancestor_accs]
    end
  end
end
