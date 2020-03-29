defmodule ExRets.Metadata.Resource.ValidationExternal do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  alias ExRets.Metadata.Resource.ValidationExternal.ValidationExternalType

  defstruct [
    :metadata_entry_id,
    :validation_external_name,
    :search_resource,
    :search_class,
    :date,
    :version,
    :validation_external_type_version,
    :validation_external_type_date,
    :validation_external_types
  ]

  @typedoc """
  The Validation External tables that are referenced in the Update Type section of the document.
  There MUST be a corresponding Validation External table for each one referenced in any of the
  `METADATA-UPDATE_TYPEs` for the Resource.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          validation_external_name: validation_external_name(),
          search_resource: search_resource(),
          search_class: search_class(),
          date: date(),
          version: version(),
          validation_external_type_version: validation_external_type_version(),
          validation_external_type_date: validation_external_type_date(),
          validation_external_types: [ValidationExternalType.t()]
        }

  @typedoc """
  A value that remains unchanged so long as the semantic definition of this field remains
  unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc """
  The unique name of this Validation External.  Each Name in the Update Type
  ValidationExternalName field MUST have a definition.
  """
  @type validation_external_name :: String.t()

  @typedoc "The ResourceID of the Resource to be searched."
  @type search_resource :: String.t()

  @typedoc "The ClassName within the Resource to be searched."
  @type search_class :: String.t()

  @typedoc """
  The latest version of this Validation External metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  The version number is advisory only.
  """
  @type version :: String.t()

  @typedoc """
  The date on which any of the content of this Validation External was last changed.  Clients MAY
  rely on this date for cache management.
  """
  @type date :: NaiveDateTime.t()

  @typedoc """
  This is the version of the Validation External Type metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @type validation_external_type_version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @type validation_external_type_date :: NaiveDateTime.t()

  def standard_xml_schema do
    root "ValidationExternal", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "ValidationExternalName" do
        text :validation_external_name, transform: &empty_string_to_nil/1
      end

      element "SearchResource" do
        text :search_resource, transform: &empty_string_to_nil/1
      end

      element "SearchClass" do
        text :search_class, transform: &empty_string_to_nil/1
      end

      element "Version" do
        text :version, transform: &empty_string_to_nil/1
      end

      element "Date" do
        text :date, transform: &parse_naive_date_time/1
      end

      element "METADATA-VALIDATION_EXTERNAL_TYPE" do
        attribute "Version", :validation_external_type_version, transform: &empty_string_to_nil/1
        attribute "Date", :validation_external_type_date, transform: &parse_naive_date_time/1

        child_element :validation_external_types, ValidationExternalType.standard_xml_schema(),
          list: true
      end
    end
  end
end
