defmodule ExRets.XmlParser do
  alias ExRets.ParsedXml

  @type t :: module()
  @type raw_xml :: String.t()

  @callback parse(raw_xml()) :: ParsedXml.t()
end
