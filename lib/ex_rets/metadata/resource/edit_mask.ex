defmodule ExRets.Metadata.Resource.EditMask do
  defstruct [
    :metadata_entry_id,
    :edit_mask_id,
    :value
  ]

  @typedoc """
  The Edit Mask table that is referenced in the Table section.  There MUST be a corresponding
  table entry for each Search `EditMaskID` referenced in the `METADATA-TABLE`.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          edit_mask_id: edit_mask_id(),
          value: value()
        }

  @typedoc """
  A value that remains unchanged so long as the semantic definition of this field remains
  unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "A unique ID for the Edit Mask."
  @type edit_mask_id :: String.t()

  @typedoc "The Regular Expression to be used."
  @type value :: String.t()
end
