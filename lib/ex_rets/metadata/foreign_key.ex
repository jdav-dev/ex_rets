defmodule ExRets.Metadata.ForeignKey do
  defstruct [
    :foreign_key_id,
    :parent_resource_id,
    :parent_class_id,
    :parent_system_name,
    :child_resource_id,
    :child_class_id,
    :child_system_name,
    :conditional_parent_field,
    :conditional_parent_value,
    :one_to_many_flag
  ]

  @type t :: %__MODULE__{
          foreign_key_id: foreign_key_id(),
          parent_resource_id: parent_resource_id(),
          parent_class_id: parent_class_id(),
          parent_system_name: parent_system_name(),
          child_resource_id: child_resource_id(),
          child_class_id: child_class_id(),
          child_system_name: child_system_name(),
          conditional_parent_field: conditional_parent_field(),
          conditional_parent_value: conditional_parent_value(),
          one_to_many_flag: one_to_many_flag()
        }

  @typedoc "A unique ID that represents the foreign key combination."
  @type foreign_key_id :: String.t()

  @typedoc """
  The `ResourceID` of the resource for which this field functions as a foreign key.  The name
  given MUST appear in the `METADATA-RESOURCE` table.
  """
  @type parent_resource_id :: String.t()

  @typedoc """
  The name of the resource class for which this field functions as a foreign key.  This name MUST
  appear in the `RESOURCE-CLASS` table for the given `ParentResourceID`.
  """
  @type parent_class_id :: String.t()

  @typedoc """
  The SystemName of the field in the given resource class that should be searched for the value
  given in this field.  This name must appear as a `SystemName` in the `METADATA-TABLE` section of
  the metadata for the `ParentClassID`, and the named item must have its Searchable attribute set
  to `true`.
  """
  @type parent_system_name :: String.t()

  @typedoc """
  The `ResourceID` of the resource for which this field functions as a foreign key.  The name
  given MUST appear in the `METADATA-RESOURCE` table.
  """
  @type child_resource_id :: String.t()

  @typedoc """
  The name of the resource class for which this field functions as a foreign key.  The name MUST
  appear in the `RESOURCE-CLASS` table for the given `ChildResourceID`
  """
  @type child_class_id :: String.t()

  @typedoc """
  The SystemName of the field in the given resource class that should be searched for the value
  given in this field. This name must appear as a SystemName in the `METADATA-TABLE` section of
  the metadata for the ChildClassID, and the named item must have its Searchable attribute set to
  `true`.
  """
  @type child_system_name :: String.t()

  @typedoc """
  The SystemName of a field in the parent's `METADATA-TABLE` that should be examined to determine
  whether this parent-child relationship should be used.  If this is `nil`, the relationship is
  unconditional.  If `ConditionalParentField` is present and nonblank, then
  `ConditionalParentValue` MUST be present and not `nil`.
  """
  @type conditional_parent_field :: String.t() | nil

  @typedoc """
  The value of the field designated by `ConditionalParentField` indicating that this relation
  should be used.  If the type of the field named in `ConditionalParentField` is numeric, then
  this value is converted to numeric type before comparison.  If the type of the field named in
  `ConditionalParentField` is character, then the shorter of the two values is padded with blanks
  and the comparison made for equal length.  If `ConditionalParentField` is present and no `nil`,
  then `ConditionalParentValue` MUST be present and not `nil`.
  """
  @type conditional_parent_value :: String.t() | nil

  @typedoc """
  A truth value that indicated if the foreign key will return multiple rows if queried from the
  source to the destination.
  """
  @type one_to_many_flag :: boolean()
end
