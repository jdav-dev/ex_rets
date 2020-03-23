defmodule ExRets.Xml do
  @opaque schema() :: map()

  @callback schema() :: schema()

  defmacro __using__(_opts) do
    quote do
      import ExRets.Xml
      import ExRets.XmlHelpers

      @behaviour ExRets.Xml

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      if Module.defines?(__MODULE__, {:schema, 0}) do
        def parse(stream, http_client_implementation) do
          xmerl_parse(schema(), stream, http_client_implementation)
        end

        defoverridable parse: 2
      end
    end
  end

  defmacro root(element_name, initial_acc, do: do_block) do
    quote bind_quoted: [element_name: element_name, initial_acc: initial_acc], unquote: true do
      {:ok, var!(pid, ExRets.Xml)} = start_agent()

      start_element(var!(pid, ExRets.Xml), element_name, nil, initial_acc, false)
      unquote(do_block)
      end_element(var!(pid, ExRets.Xml))

      {:ok, schema} = stop_agent(var!(pid, ExRets.Xml))
      schema
    end
  end

  defmacro element(element_name, do: do_block) do
    quote do
      start_element(var!(pid, ExRets.Xml), unquote(element_name), nil, nil, false)
      unquote(do_block)
      end_element(var!(pid, ExRets.Xml))
    end
  end

  defmacro element(element_name, parent_acc_field, initial_acc, opts \\ [], do: do_block) do
    quote bind_quoted: [
            element_name: element_name,
            parent_acc_field: parent_acc_field,
            initial_acc: initial_acc,
            opts: opts
          ],
          unquote: true do
      list? = is_list_from_opts(opts)

      start_element(var!(pid, ExRets.Xml), element_name, parent_acc_field, initial_acc, list?)
      unquote(do_block)
      end_element(var!(pid, ExRets.Xml))
    end
  end

  defmacro attribute(attribute_name, acc_field, opts \\ []) do
    quote bind_quoted: [attribute_name: attribute_name, acc_field: acc_field, opts: opts] do
      transform_fun = transform_fun_from_opts(opts)
      add_attribute(var!(pid, ExRets.Xml), attribute_name, acc_field, transform_fun)
    end
  end

  defmacro text(parent_acc_field, opts \\ []) do
    quote bind_quoted: [parent_acc_field: parent_acc_field, opts: opts] do
      transform_fun = transform_fun_from_opts(opts)
      add_text(var!(pid, ExRets.Xml), parent_acc_field, transform_fun)
    end
  end

  def transform_fun_from_opts(opts) do
    case Keyword.fetch(opts, :transform) do
      {:ok, transform_fun} -> transform_fun
      :error -> & &1
    end
  end

  def is_list_from_opts(opts) do
    case Keyword.fetch(opts, :list) do
      {:ok, true} -> true
      _ -> false
    end
  end

  def start_agent do
    Agent.start_link(fn -> %{current_path: [], elements: %{}} end)
  end

  def start_element(pid, element_name, parent_acc_field, initial_acc, list?) do
    Agent.update(pid, fn %{current_path: current_path, elements: elements} ->
      current_path = [to_charlist(element_name) | current_path]

      elements =
        Map.put(elements, current_path, %{
          attributes: %{},
          initial_acc: initial_acc,
          list?: list?,
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

  def xmerl_parse(schema, stream, http_client_implementation) do
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
