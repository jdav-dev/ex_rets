defmodule ExRets.Xml.Schema do
  alias ExRets.Xml.SchemaBuilder

  @opaque t :: %{nonempty_list(nonempty_charlist()) => element()}
  @opaque element :: %{
            attributes: %{nonempty_charlist() => {atom(), (binary() -> any())}},
            initial_acc: struct(),
            list?: boolean(),
            parent_acc_field: atom(),
            text: nil | {atom(), (binary() -> any())}
          }

  defmacro root(element_name, initial_acc, do: do_block) do
    quote bind_quoted: [element_name: element_name, initial_acc: initial_acc], unquote: true do
      {:ok, var!(pid, ExRets.Xml)} = SchemaBuilder.start_builder()

      SchemaBuilder.start_element(var!(pid, ExRets.Xml), element_name, nil, initial_acc)
      unquote(do_block)
      SchemaBuilder.end_element(var!(pid, ExRets.Xml))

      {:ok, schema} = SchemaBuilder.stop_builder(var!(pid, ExRets.Xml))
      schema
    end
  end

  defmacro element(element_name, do: do_block) do
    quote do
      SchemaBuilder.start_element(var!(pid, ExRets.Xml), unquote(element_name), nil, nil)
      unquote(do_block)
      SchemaBuilder.end_element(var!(pid, ExRets.Xml))
    end
  end

  defmacro child_element(parent_acc_field, schema, opts \\ []) do
    quote bind_quoted: [parent_acc_field: parent_acc_field, schema: schema, opts: opts] do
      SchemaBuilder.add_child_element(var!(pid, ExRets.Xml), parent_acc_field, schema, opts)
    end
  end

  defmacro attribute(attribute_name, acc_field, opts \\ []) do
    quote bind_quoted: [attribute_name: attribute_name, acc_field: acc_field, opts: opts] do
      SchemaBuilder.add_attribute(var!(pid, ExRets.Xml), attribute_name, acc_field, opts)
    end
  end

  defmacro text(parent_acc_field, opts \\ []) do
    quote bind_quoted: [parent_acc_field: parent_acc_field, opts: opts] do
      SchemaBuilder.add_text(var!(pid, ExRets.Xml), parent_acc_field, opts)
    end
  end
end
