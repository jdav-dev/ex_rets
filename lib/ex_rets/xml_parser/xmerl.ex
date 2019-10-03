defmodule ExRets.XmlParser.Xmerl do
  require Logger
  require Record

  alias ExRets.ParsedXml

  @xmerl_records Record.extract_all(from_lib: "xmerl/include/xmerl.hrl")
  Enum.each(@xmerl_records, fn {name, record} -> Record.defrecordp(name, record) end)

  def parse(xml_string) do
    xml_string
    |> to_charlist()
    |> :xmerl_scan.string(acc_fun: &ignore_whitespace_only_elements/3)
    |> walk_xml()
  end

  defp ignore_whitespace_only_elements(xmlText(value: value) = parsed_entity, acc, global_state) do
    case value |> to_string() |> String.trim() do
      "" -> {acc, global_state}
      _ -> {[parsed_entity | acc], global_state}
    end
  end

  defp ignore_whitespace_only_elements(parsed_entity, acc, global_state) do
    {[parsed_entity | acc], global_state}
  end

  defp walk_xml({xml_record, _rest}) do
    walk_xml(xml_record)
  end

  defp walk_xml(xmlElement(name: name, attributes: attributes, content: content)) do
    %ParsedXml{name: name, attributes: map_attributes(attributes), elements: walk_xml(content)}
  end

  defp walk_xml(content) when is_list(content) do
    Enum.map(content, &walk_xml/1)
  end

  defp walk_xml(xmlText(value: value)) do
    value
    |> to_string()
    |> String.trim()
  end

  defp walk_xml(other_record) do
    Logger.debug("Dropping unsupported XML record\n\tRecord: #{inspect(other_record)}")
  end

  defp map_attributes(attributes) do
    Enum.into(attributes, %{}, &map_attribute/1)
  end

  defp map_attribute(xmlAttribute(name: name, value: value)) do
    {name, to_string(value)}
  end
end
