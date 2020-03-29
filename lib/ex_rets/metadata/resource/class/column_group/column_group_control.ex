defmodule ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupControl do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  defstruct [
    :metadata_entry_id,
    :low_value,
    :high_value
  ]

  @typedoc """
  The valid ranges of values that the specified SystemName may have that control the display of
  the Column Group.  If the SystemName contains any of the values that fall within the ranges
  specified in this table, the Column Group may be displayed.  If it does not, the Column Group
  should not be displayed.  The data is returned as a list of high and low values that determine
  whether the Column Group should be displayed.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          low_value: low_value(),
          high_value: high_value()
        }

  @typedoc """
  A value that never changes as long as the semantic definition of this entry remains unchanged.
  In particular, it should be managed so as to allow the client to detect changes to an individual
  pair of High/Low values.
  """
  @type metadata_entry_id :: String.t()

  @typedoc """
  The minimum value that the ControlSystemName field of the ColumnGroup is allowed to have in
  order to display the ColumnGroup.  It is expected that the actual data type returned is
  interpreted as per the data type of the ControlSystemName of the ColumnGroup.
  """
  @type low_value :: String.t()

  @typedoc """
  The maximum value that the ControlSystemName field of the ColumnGroup is allowed to have in
  order to display the ColumnGroup.  It is expected that the actual data type returned is
  interpreted as per the data type of the ControlSystemName of the ColumnGroup.  If the
  restricting data is not a range, then HighValue may be `nil`.
  """
  @type high_value :: String.t() | nil

  def standard_xml_schema do
    root "ColumnGroupControl", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "LowValue" do
        text :low_value, transform: &empty_string_to_nil/1
      end

      element "HighValue" do
        text :high_value, transform: &empty_string_to_nil/1
      end
    end
  end
end
