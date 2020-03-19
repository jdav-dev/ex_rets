defmodule ExRets.Metadata.Resource.SearchHelp do
  defstruct [
    :metadata_entry_id,
    :search_help_id,
    :value
  ]

  @typedoc """
  The Search Help text tables that are referenced in the Table section.  There MUST be a
  corresponding table entry for each Search HelpTextID referenced in the `METADATA-TABLE`.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          search_help_id: search_help_id(),
          value: value()
        }

  @typedoc """
  A value that never changes so long as the semantic definition of this entry remains unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "A unique ID for the help text."
  @type search_help_id :: String.t()

  @typedoc "The value to be displayed to the user."
  @type value :: String.t()
end
