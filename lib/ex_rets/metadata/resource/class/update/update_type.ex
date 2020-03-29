defmodule ExRets.Metadata.Resource.Class.Update.UpdateType do
  defstruct [
    :metadata_entry_id,
    :system_name,
    :sequence,
    :attributes,
    :default,
    :validation_expression_id,
    :update_help_id,
    :validation_external_name,
    :max_update,
    :search_result_order,
    :search_query_order
  ]

  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          system_name: system_name(),
          sequence: sequence(),
          attributes: attributes(),
          default: default(),
          validation_expression_id: validation_expression_id(),
          update_help_id: update_help_id(),
          validation_external_name: validation_external_name(),
          max_update: max_update(),
          search_result_order: search_result_order(),
          search_query_order: search_query_order()
        }

  @typedoc """
  A value that never changes as long as the semantic definition of this entry remains unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "This is the SystemName of the field."
  @type system_name :: String.t()

  @typedoc "Sequence number of the field, representing the order of entry"
  @type sequence :: integer()

  @typedoc """
  Multiple entries are separated by commas.

    * `1` - Display Only - Field may not be changed.
    * `2` - Required - Field may not be left blank.
    * `3` - Autopop - Field is populated by the server.
    * `4` - Interactive-Validate - When changed, the client can validate the field only by
      contacting the server.  All fields listed as `AdditionalField` MUST also be passed.
    * `5` - Clear On Cloning - Field SHOULD be cleared when the containing record is cloned.
    * `6` - Autopop Required - Field is mandatory when calling the Update transaction for
      Auto-population (validate-flag=1).
    * `7` - Hidden - Field may be used in ValidationExpression, but is to remain hidden from the
      user.
  """
  @type attributes :: [integer()]

  @typedoc "Default value of field (i.e. value if not specified by user)"
  @type default :: String.t()

  @typedoc "The names of the ValidationExpressions to use."
  @type validation_expression_id :: [String.t()]

  @typedoc "The name of the entry in the `METADATA-UPDATE_HELP` table."
  @type update_help_id :: String.t()

  @typedoc "The name of the ValidationExternal to use."
  @type validation_external_name :: String.t()

  @typedoc """
  For LookupMulti fields, the maximum number of values that may be specified for the field.  This
  value has no meaning for fields with any other interpretation.
  """
  @type max_update :: integer()

  @typedoc """
  The order that fields should appear in a default one-liner search result that is executed in
  order to give the user a list of existing records to select from for updating.  Fields that
  should not appear in the default one-line format should have a value of "0".  Fields that should
  never be visible to the user should have a value of "-1".
  """
  @type search_result_order :: integer()

  @typedoc """
  The order that fields should appear in a default search screen that is executed in order to give
  the user a list of existing records to select from for updating.  Fields that should not appear
  in the default search screen should have a value of "0".  Fields that should never be visible to
  the user should have a value of "-1".
  """
  @type search_query_order :: integer()

  def parse_attributes(value) do
    value
    |> String.split(",")
    |> Enum.map(&ExRets.StringParsers.parse_integer/1)
  end

  def parse_validation_expression_id(value) do
    value
    |> String.split(",")
    |> Enum.map(&ExRets.StringParsers.empty_string_to_nil/1)
    |> Enum.reject(&is_nil/1)
  end
end
