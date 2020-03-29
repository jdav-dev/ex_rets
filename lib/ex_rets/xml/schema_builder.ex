defmodule ExRets.Xml.SchemaBuilder do
  def start_builder do
    Agent.start_link(fn -> %{current_path: [], elements: %{}} end)
  end

  def start_element(pid, element_name, parent_acc_field, initial_acc, opts) do
    list? = is_list_from_opts(opts)

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

  def add_child_element(pid, parent_acc_field, %{elements: incoming_elements} = _schema, opts) do
    list? = is_list_from_opts(opts)

    Agent.update(pid, fn %{current_path: current_path, elements: elements} = state ->
      elements =
        incoming_elements
        |> Enum.into(%{}, fn {path, element} ->
          element =
            case path do
              [_] = _root_element -> %{element | parent_acc_field: parent_acc_field, list?: list?}
              _ -> element
            end

          {path ++ current_path, element}
        end)
        |> Map.merge(elements)

      %{state | elements: elements}
    end)
  end

  def add_attribute(pid, attribute_name, acc_field, opts) do
    transform_fun = transform_fun_from_opts(opts)

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

  def add_text(pid, parent_acc_field, opts) do
    transform_fun = transform_fun_from_opts(opts)

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

  def stop_builder(pid) do
    state = Agent.get(pid, & &1)
    event_state = %{acc_stack: [], characters: [], current_path: [], elements: state.elements}

    with :ok <- Agent.stop(pid) do
      {:ok, event_state}
    end
  end

  defp is_list_from_opts(opts) do
    case Keyword.fetch(opts, :list) do
      {:ok, true} -> true
      _ -> false
    end
  end

  defp transform_fun_from_opts(opts) do
    case Keyword.fetch(opts, :transform) do
      {:ok, transform_fun} -> transform_fun
      :error -> & &1
    end
  end
end
