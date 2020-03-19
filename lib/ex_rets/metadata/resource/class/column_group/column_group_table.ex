defmodule ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupTable do
  defstruct [
    :metadata_entry_id,
    :system_name,
    :column_group_set_name,
    :long_name,
    :short_name,
    :display_order,
    :display_length,
    :display_height,
    :immediate_refresh
  ]

  @typedoc """
  The set of SystemNames that are to be displayed within a Column and the order in which they are
  to be displayed.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          system_name: system_name(),
          column_group_set_name: column_group_set_name(),
          long_name: long_name(),
          short_name: short_name(),
          display_order: display_order(),
          display_length: display_length(),
          display_height: display_height(),
          immediate_refresh: immediate_refresh()
        }

  @typedoc """
  A value that never changes as long as the semantic definition of this entry remains unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc """
  The SystemName of the field that is to be displayed in the ColumnGroup.  This MUST be a valid
  SystemName for this Class.  A SystemName MUST be unique within the ColumnGroup.  This MUST not
  be specified if a ColumnGroupSetName is specified. Both `t:system_name/0` and
  `t:column_group_set_name/0` may be `nil`. vIn this case, the Client may use this as a spacer.
  """
  @type system_name :: String.t() | nil

  @typedoc """
  The name of a ColumnGroupSet to display in place of a single field.  It is expected that this is
  a ColumnGroupSet that does not display a large number of columns.  This MUST not be specified if
  a SystemName is specified.  The ColumnGroupSet MUST not contain a ColumGroup that also specifies
  a ColumnGroupSetName in the COLUMN_GROUP_TABLE metadata.  Both `t:system_name/0` and
  `t:column_group_set_name/0` may be `nil`.v In this case, the Client may use this as a spacer.
  """
  @type column_group_set_name :: String.t() | nil

  @typedoc """
  The name of the Column Group Table (data field) as it is known to the user.  This is a
  localizable, human-readable string.  Use of this field is implementation-defined; it is expected
  that clients will use this value as a title for this Column Group when it appears on a report.
  """
  @type long_name :: String.t()

  @typedoc """
  An abbreviated field name that is also localizable and human-readable.  Use of this field is
  implementation-defined; it is expected that clients will use this field in human-interface
  elements such as lookups.
  """
  @type short_name :: String.t()

  @typedoc """
  The order within the ColumnGroup that this SystemName is to be displayed in.  DisplayOrder
  values MAY contain gaps and may have the same value as other columns.  If multiple columns have
  the same value, the client SHOULD display the columns in Alphabetical order.
  """
  @type display_order :: non_neg_integer()

  @typedoc "The number of characters to allow when displaying data for this column."
  @type display_length :: non_neg_integer()

  @typedoc """
  The number of rows to display the data in.  A value greater than one in this column implies a
  multi-line data entry field of DisplayLength width.  If users enter data into this field that is
  longer than will fit within this text box, it is expected that the field will scroll to allow
  further data entry.
  """
  @type display_height :: non_neg_integer()

  @typedoc """
  Tndicates whether a change to this field by the user should cause an automatic GUI refresh.
  This is primarily intended for use
  """
  @type immediate_refresh :: boolean()
end
