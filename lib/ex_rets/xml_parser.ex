defprotocol ExRets.XmlParser do
  # def xml_event_fun(xml_collectable)

  # @spec element(t, element :: String.t(), attributes :: [{String.t(), String.t()}]) :: {:}
  # def element(xml_collectable, element, attributes)

  @callback start_element(name :: String.t(), attributes :: [{String.t(), String.t()}]) ::
              {:ok, any()} | :skip
end
