defmodule ExRets.Metadata.Resource.SearchHelp do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  defstruct [
    :metadata_entry_id,
    :search_help_id,
    :value
  ]

  @typedoc """
  The Search Help text tables that are referenced in the Table section.  There MUST be a
  corresponding table entry for each Search HelpTextID referenced in the `METADATA-TABLE`.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          search_help_id: search_help_id(),
          value: value()
        }

  @typedoc """
  A value that never changes so long as the semantic definition of this entry remains unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "A unique ID for the help text."
  @type search_help_id :: String.t()

  @typedoc "The value to be displayed to the user."
  @type value :: String.t()

  def standard_xml_schema do
    root "SearchHelp", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "SearchHelpID" do
        text :search_help_id, transform: &empty_string_to_nil/1
      end

      element "Value" do
        text :value, transform: &empty_string_to_nil/1
      end
    end
  end
end
