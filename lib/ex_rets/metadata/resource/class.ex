defmodule ExRets.Metadata.Resource.Class do
  alias ExRets.Metadata.Resource.Class.ColumnGroup
  alias ExRets.Metadata.Resource.Class.ColumnGroupSet
  alias ExRets.Metadata.Resource.Class.Field
  alias ExRets.Metadata.Resource.Class.Update

  defstruct [
    :class_name,
    :standard_name,
    :visible_name,
    :description,
    :field_version,
    :field_date,
    :fields,
    :update_version,
    :update_date,
    :updates,
    :class_timestamp,
    :deleted_flag_field,
    :deleted_flag_value,
    :has_key_index,
    :offset_support,
    :column_group_set_version,
    :column_group_set_date,
    :column_group_sets,
    :column_group_version,
    :column_group_date,
    :column_groups
  ]

  @type t :: %__MODULE__{
          class_name: class_name(),
          standard_name: standard_name(),
          visible_name: visible_name(),
          description: description(),
          field_version: field_version(),
          field_date: field_date(),
          fields: [Field.t()],
          update_version: update_version(),
          update_date: update_date(),
          updates: [Update.t()],
          class_timestamp: class_timestamp(),
          deleted_flag_field: deleted_flag_field(),
          deleted_flag_value: deleted_flag_value(),
          has_key_index: has_key_index(),
          offset_support: offset_support(),
          column_group_set_version: column_group_set_version(),
          column_group_set_date: column_group_set_date(),
          column_group_sets: [ColumnGroupSet.t()],
          column_group_version: column_group_version(),
          column_group_date: column_group_date(),
          column_groups: [ColumnGroup.t()]
        }

  @typedoc "The name which acts as a unique ID for the class."
  @type class_name :: String.t()

  @typedoc "The Well-Known Class name"
  @type standard_name :: String.t()

  @typedoc "The user-visible name of the class."
  @type visible_name :: String.t()

  @typedoc "A user-visible description of the class."
  @type description :: String.t()

  @typedoc "The version of the Field (Table) metadata that describes this Class.  The version
  number is advisory only."
  @type field_version :: String.t()

  @typedoc """
  The date on which the Field (Table) metadata for this Class was last changed.  Clients MAY rely
  on this date for cache management.
  """
  @type field_date :: NaiveDateTime.t()

  @typedoc """
  The latest version of any of the Update metadata for this Class.  A `nil` version indicates no
  Update is available for this Class. The version number is advisory only.
  """
  @type update_version :: String.t() | nil

  @typedoc """
  The date on which any of the Update metadata for this Class was last changed.  Clients MAY rely
  on this data for cache management.  A `nil` date indicates no Update is available for this
  Class.
  """
  @type update_date :: NaiveDateTime.t() | nil

  @typedoc """
  The `SystemName` of the field in the `METADATA-TABLE` that acts as the last-change timestamp for
  this class.
  """
  @type class_timestamp :: String.t()

  @typedoc """
  The `SystemName` of the field in the `METADATA-TABLE` that indicates that the record is
  logically deleted.  If this element is specified, then `DeletedFlagValue` MUST be specified as
  well.
  """
  @type deleted_flag_field :: String.t()

  @typedoc """
  The value of the field designated by `DeletedFlagField` indicating that a record has been
  logically deleted.  If thetype of the field named by `DeletedFlagField` is numeric, then this
  value is converted to a number before comparison.  If the type of the field named by
  `DeletedFlagField` is character, then the shorter of the two values is padded with blanks and
  the comparison made for equal length.
  """
  @type deleted_flag_value :: String.t()

  @typedoc """
  When true, indicates that the Class supports the retrieval of key data for fields advertised in
  the Field (Table) Metadata as InKeyIndex.
  """
  @type has_key_index :: boolean()

  @typedoc """
  When true, indicates that the server will honor the Offset parameter when searching this class.
  When false, indicates that the server does not support the Offset functionality for this class.
  """
  @type offset_support :: boolean()

  @typedoc """
  This is the version of the Column Group Set metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @type column_group_set_version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @type column_group_set_date :: NaiveDateTime.t()

  @typedoc """
  This is the version of the Column Group metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @type column_group_version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @type column_group_date :: NaiveDateTime.t()
end
