defmodule ExRets.Metadata.Resource.Lookup.LookupType do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  defstruct [
    :metadata_entry_id,
    :long_value,
    :short_value,
    :value
  ]

  @typedoc """
  The content of a lookup table that is referenced by the LookupName in the Table section. There
  MUST be a corresponding lookup table for every "Lookup" and "LookupMulti".
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          long_value: long_value(),
          short_value: short_value(),
          value: value()
        }

  @typedoc """
  A value that never changes so long as the semantic definition of this entry remains unchanged.
  In particular, it should be managed so as to allow the client to detect changes to the Value.
  """
  @type metadata_entry_id :: String.t()

  @typedoc """
  The value of the field as it is known to the user.  This is a localizable, human-readable
  string.  Use of this field is implementation-defined; expected uses include displays on reports
  and other presentation contexts.  This is the value that is returned for a COMPACT-DECODED or
  STANDARD-XML format request.
  """
  @type long_value :: String.t()

  @typedoc """
  An abbreviated field value that is also localizable and human-readable.  Use of this field is
  implementation-defined; expected uses include picklist values and other human interface
  elements.
  """
  @type short_value :: String.t()

  @typedoc """
  The value to be sent to the server when performing a search.  This is the value that is returned
  for a COMPACT format request.
  """
  @type value :: String.t()

  def standard_xml_schema do
    root "LookupType", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "LongValue" do
        text :long_value, transform: &empty_string_to_nil/1
      end

      element "ShortValue" do
        text :short_value, transform: &empty_string_to_nil/1
      end

      element "Value" do
        text :value, transform: &empty_string_to_nil/1
      end
    end
  end
end
