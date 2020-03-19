defmodule ExRets.Metadata.Resource.ValidationExternal.ValidationExternalType do
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
end
