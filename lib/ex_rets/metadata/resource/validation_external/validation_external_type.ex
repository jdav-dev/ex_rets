defmodule ExRets.Metadata.Resource.ValidationExternal.ValidationExternalType do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  defstruct [
    :metadata_entry_id,
    :search_field,
    :display_field,
    :result_fields
  ]

  @typedoc """
  The Validation External Type tables that are referenced in the Table section of the document.
  There MUST be a corresponding Validation External Type table for each one referenced in the
  METADATA-UPDATE_TYPEs for the Resource.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          search_field: search_field(),
          display_field: display_field(),
          result_fields: result_fields()
        }

  @typedoc """
  A value that remains unchanged so long as the semantic definition of this field remains
  unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "A list of valid fields using `SystemName`."
  @type search_field :: [String.t()]

  @typedoc "A list of valid fields using `SystemName`."
  @type display_field :: [String.t()]

  @typedoc """
  A list of valid field tuples.  The first is a target field in the table being updated and the
  second is a source field in the table being searched.  The fields use `SystemName`.
  """
  @type result_fields :: [{String.t(), String.t()}]

  def standard_xml_schema do
    root "ValidationExternalType", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "SearchField" do
        text :search_field, transform: &empty_string_to_nil/1
      end

      element "DisplayField" do
        text :display_field, transform: &empty_string_to_nil/1
      end

      element "ResultFields" do
        text :result_fields, transform: &empty_string_to_nil/1
      end
    end
  end
end
