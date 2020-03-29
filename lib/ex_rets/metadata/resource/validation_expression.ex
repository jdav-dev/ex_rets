defmodule ExRets.Metadata.Resource.ValidationExpression do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  defstruct [
    :metadata_entry_id,
    :validation_expression_id,
    :validation_expression_type,
    :value,
    :message,
    :is_case_sensitive
  ]

  @typedoc """
  The ValidationExpression table.  There MUST be a corresponding table entry for each
  ValidationExpressionID referenced in the set of `METADATA-UPDATE_TYPE` for a Resource.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          validation_expression_id: validation_expression_id(),
          validation_expression_type: validation_expression_type(),
          value: value(),
          message: message(),
          is_case_sensitive: is_case_sensitive()
        }

  @typedoc """
  A value that remains unchanged so long as the semantic definition of this field remains
  unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "A unique ID for the ValidationExpression."
  @type validation_expression_id :: String.t()

  @typedoc "A validation expression type."
  @type validation_expression_type :: String.t()

  @typedoc "The test expression to be evaluated."
  @type value() :: String.t()

  @typedoc """
  Message to be shown to the user if a field is rejected, or a warning is issued as a result of
  this validation expression.
  """
  @type message :: String.t()

  @typedoc "If `true`, the string comparisons in the expressions are case sensitive."
  @type is_case_sensitive :: boolean()

  def standard_xml_schema do
    root "ValidationExpression", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "ValidationExpressionID" do
        text :validation_expression_id, transform: &empty_string_to_nil/1
      end

      element "ValidationExpressionType" do
        text :validation_expression_type, transform: &empty_string_to_nil/1
      end

      element "Value" do
        text :value, transform: &empty_string_to_nil/1
      end

      element "Message" do
        text :message, transform: &empty_string_to_nil/1
      end

      element "IsCaseSensitive" do
        text :is_case_sensitive, transform: &parse_boolean/1
      end
    end
  end
end
