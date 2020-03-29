defmodule ExRets.Metadata.Resource.Class.ColumnGroup do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  alias ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupControl
  alias ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupNormalization
  alias ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupTable

  defstruct [
    :metadata_entry_id,
    :column_group_name,
    :control_system_name,
    :long_name,
    :short_name,
    :description,
    :column_group_control_version,
    :column_group_control_date,
    :column_group_controls,
    :column_group_table_version,
    :column_group_table_date,
    :column_group_tables,
    :column_group_normalization_version,
    :column_group_normalization_date,
    :column_group_normalizations
  ]

  @typedoc """
  Grouping element which should be used to group columns together in any GUI system that is
  designed in order to satisfy the display requirements of an MLS.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          column_group_name: column_group_name(),
          control_system_name: control_system_name(),
          long_name: long_name(),
          short_name: short_name(),
          description: description(),
          column_group_control_version: column_group_control_version(),
          column_group_control_date: column_group_control_date(),
          column_group_controls: [ColumnGroupControl.t()],
          column_group_table_version: column_group_table_version(),
          column_group_table_date: column_group_table_date(),
          column_group_tables: [ColumnGroupTable.t()],
          column_group_normalization_version: column_group_normalization_version(),
          column_group_normalization_date: column_group_normalization_date(),
          column_group_normalizations: [ColumnGroupNormalization.t()]
        }

  @typedoc """
  A value that never changes as long as the semantic definition of this entry remains unchanged.
  In particular, it should be managed so as to allow the client to detect changes to the
  ColumnGroupName.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "The name that uniquely identifies this Column Group within the Class."
  @type column_group_name :: String.t()

  @typedoc """
  The SystemName of the Table Metadata that identifies the data element that is used to control
  the display of this Column Group.
  """
  @type control_system_name :: String.t()

  @typedoc """
  The name of the Column Group as it is known to the user.  This is a localizable, human-readable
  string.  Use of this field is implementation-defined; it is expected that clients will use this
  value as a title for this Column Group when it appears on a report.
  """
  @type long_name :: String.t()

  @typedoc """
  An abbreviated field name that is also localizable and human-readable.  Use of this field is
  implementation-defined; it is expected that clients will use this field in human-interface
  elements such as lookups.
  """
  @type short_name :: String.t()

  @typedoc "A brief description of the purpose for this Column Group."
  @type description :: String.t()

  @typedoc """
  This is the version of the Column Group Control metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @type column_group_control_version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @type column_group_control_date :: NaiveDateTime.t()

  @typedoc """
  This is the version of the Column Group metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @type column_group_table_version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @type column_group_table_date :: NaiveDateTime.t()

  @typedoc """
  This is the version of the Column Group metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @type column_group_normalization_version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @type column_group_normalization_date :: NaiveDateTime.t()

  def standard_xml_schema do
    root "ColumnGroup", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "ColumnGroupName" do
        text :column_group_name, transform: &empty_string_to_nil/1
      end

      element "ControlSystemName" do
        text :control_system_name, transform: &empty_string_to_nil/1
      end

      element "LongName" do
        text :long_name, transform: &empty_string_to_nil/1
      end

      element "ShortName" do
        text :short_name, transform: &empty_string_to_nil/1
      end

      element "Description" do
        text :description, transform: &empty_string_to_nil/1
      end

      element "METADATA-COLUMN_GROUP_CONTROL" do
        attribute "Version", :column_group_control_version, transform: &empty_string_to_nil/1
        attribute "Date", :column_group_control_date, transform: &parse_naive_date_time/1
        child_element :column_group_controls, ColumnGroupControl.standard_xml_schema(), list: true
      end

      element "METADATA-COLUMN_GROUP_TABLE" do
        attribute "Version", :column_group_table_version, transform: &empty_string_to_nil/1
        attribute "Date", :column_group_table_date, transform: &parse_naive_date_time/1
        child_element :column_group_tables, ColumnGroupTable.standard_xml_schema(), list: true
      end

      element "METADATA-COLUMN_GROUP_NORMALIZATION" do
        attribute "Version", :column_group_normalization_version,
          transform: &empty_string_to_nil/1

        attribute "Date", :column_group_normalization_date, transform: &parse_naive_date_time/1

        child_element :column_group_normalizations,
                      ColumnGroupNormalization.standard_xml_schema(),
                      list: true
      end
    end
  end
end
