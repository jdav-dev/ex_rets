defmodule ExRets.Metadata.Resource.UpdateHelp do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  defstruct [
    :metadata_entry_id,
    :update_help_id,
    :value
  ]

  @typedoc """
  The Update Help Text tables that are referenced in the Update Type section of the document.
  There MUST be a corresponding table entry for each Update Help Text ID referenced in any of the
  `METADATA-UPDATE_TYPEs`.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          update_help_id: update_help_id(),
          value: value()
        }

  @typedoc """
  A value that remains unchanged so long as the semantic definition of this field remains
  unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "A unique ID for the help text."
  @type update_help_id :: String.t()

  @typedoc "The value to be displayed to the user."
  @type value :: String.t()

  def standard_xml_schema do
    root "UpdateHelp", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "UpdateHelpID" do
        text :update_help_id, transform: &empty_string_to_nil/1
      end

      element "Value" do
        text :value, transform: &empty_string_to_nil/1
      end
    end
  end
end
