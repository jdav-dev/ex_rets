defmodule ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupNormalization do
  defstruct [
    :metadata_entry_id,
    :type_identifier,
    :sequence,
    :column_label,
    :system_name
  ]

  @typedoc """
  A grid that can be used by a client to display related fields in a manner more appropriate for
  data entry.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          type_identifier: type_identifier(),
          sequence: sequence(),
          column_label: column_label(),
          system_name: system_name()
        }

  @typedoc """
  A value that never changes as long as the semantic definition of this entry remains unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc """
  Y Axis – Row Label – The Label that is to be displayed on the left side of the screen that
  identifies the Type of data that the user is entering.
  """
  @type type_identifier :: String.t()

  @typedoc """
  Y Axis – Row Sequence – The Sequence number that is to be displayed on the left side of the
  screen after the TypeIdentifier.  This itemizes the Type of data that the user is entering.
  """
  @type sequence :: non_neg_integer()

  @typedoc """
  X Axis – Column Label – This is the label that is to appear at the top of the screen for data
  within this column.  It is expected that all data in this grid with the same ColumnLabel be
  displayed in the same column on the screen.
  """
  @type column_label :: String.t()

  @typedoc """
  The SystemName of the field that is to be displayed in this position in the Grid for the
  ColumnGroup.  This MUST be a valid SystemName for this Class and MUST be within the
  ColumnGroupTable of the ColumnGroup.  Fields that appear within a ColumnGroup, but not within
  the Normalization for the ColumnGroup, are to be treated as separate data entry fields that are
  not part of the grid.  The SystemName MUST be unique within the ColumnGroup.
  """
  @type system_name :: String.t()
end
