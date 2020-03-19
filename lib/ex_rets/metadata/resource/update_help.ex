defmodule ExRets.Metadata.Resource.UpdateHelp do
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
end
