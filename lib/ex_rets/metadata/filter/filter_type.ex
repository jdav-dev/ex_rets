defmodule ExRets.Metadata.Filter.FilterType do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  defstruct [
    :filter_type_id,
    :parent_value,
    :child_value
  ]

  @type t :: %__MODULE__{
          filter_type_id: filter_type_id(),
          parent_value: parent_value(),
          child_value: child_value()
        }

  @typedoc "The name which acts as a unique ID for this filter type."
  @type filter_type_id :: String.t()

  @typedoc "The LookupType Value field for the LookupType in the parent lookup."
  @type parent_value :: String.t()

  @typedoc "The LookupType Value field for the LookupType in the child lookup."
  @type child_value :: String.t()

  def standard_xml_schema do
    root "FilterType", %__MODULE__{} do
      element "FilterTypeID" do
        text :filter_type_id, transform: &empty_string_to_nil/1
      end

      element "ParentValue" do
        text :parent_value, transform: &empty_string_to_nil/1
      end

      element "ChildValue" do
        text :child_value, transform: &empty_string_to_nil/1
      end
    end
  end
end
