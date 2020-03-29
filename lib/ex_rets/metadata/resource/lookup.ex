defmodule ExRets.Metadata.Resource.Lookup do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  alias ExRets.Metadata.Resource.Lookup.LookupType

  defstruct metadata_entry_id: nil,
            lookup_name: nil,
            visible_name: nil,
            lookup_type_version: nil,
            lookup_type_date: nil,
            lookup_types: [],
            filter_id: nil,
            not_shown_by_default: nil

  @typedoc """
  The lookup tables that are referenced by the LookupName in the Table section.  There MUST be a
  corresponding lookup table for every "LookupName".
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          lookup_name: lookup_name(),
          visible_name: visible_name(),
          lookup_type_version: lookup_type_version(),
          lookup_type_date: lookup_type_date(),
          lookup_types: [LookupType.t()],
          filter_id: filter_id(),
          not_shown_by_default: not_shown_by_default()
        }

  @typedoc """
  A value that never changes as long as the semantic definition of this entry remains unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc """
  The name of Lookup Table.  There MUST be an entry for each LookupName value used inthe Table
  metadata.
  """
  @type lookup_name :: String.t()

  @typedoc "A description of the table that is human-readable"
  @type visible_name :: String.t()

  @typedoc """
  The latest version of this Lookup Table metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  The version number is advisory only.
  """
  @type lookup_type_version :: String.t()

  @typedoc """
  The date on which any of the content of this Lookup was last changed.  Clients MAY rely on this
  date for cache management.
  """
  @type lookup_type_date :: NaiveDateTime.t()

  @typedoc """
  The FilterID of an existing filter.  If present, the range of valid LookupType values in this
  lookup is limited by the value of a parent lookup.
  """
  @type filter_id :: String.t() | nil

  @typedoc """
  If `true`, the server will, by default, not include the LookupType data of this lookup in any
  metadata request unless specifically asked to, using the LookupFilter argument in the
  GetMetadata Transaction.  This field MUST be set to `false` unless a FilterID is not `nil`.
  """
  @type not_shown_by_default :: boolean()

  def standard_xml_schema do
    root "Lookup", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "LookupName" do
        text :lookup_name, transform: &empty_string_to_nil/1
      end

      element "VisibleName" do
        text :visible_name, transform: &empty_string_to_nil/1
      end

      element "LookupTypeVersion" do
        text :lookup_type_version, transform: &empty_string_to_nil/1
      end

      element "LookupTypeDate" do
        text :lookup_type_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-LOOKUP_TYPE" do
        attribute "Version", :lookup_type_version, transform: &empty_string_to_nil/1
        attribute "Date", :lookup_type_date, transform: &parse_naive_date_time/1
        child_element :lookup_types, LookupType.standard_xml_schema(), list: true
      end

      element "FilterID" do
        text :filter_id, transform: &empty_string_to_nil/1
      end

      element "NotShownByDefault" do
        text :not_shown_by_default, transform: &parse_boolean/1
      end
    end
  end
end
