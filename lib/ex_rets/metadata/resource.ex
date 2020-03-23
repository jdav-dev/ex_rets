defmodule ExRets.Metadata.Resource do
  alias ExRets.Metadata.Resource.Class
  alias ExRets.Metadata.Resource.EditMask
  alias ExRets.Metadata.Resource.Lookup
  alias ExRets.Metadata.Resource.Object
  alias ExRets.Metadata.Resource.SearchHelp
  alias ExRets.Metadata.Resource.UpdateHelp
  alias ExRets.Metadata.Resource.ValidationExpression
  alias ExRets.Metadata.Resource.ValidationExternal

  defstruct resource_id: nil,
            standard_name: nil,
            visible_name: nil,
            description: nil,
            key_field: nil,
            class_count: nil,
            class_version: nil,
            class_date: nil,
            classes: [],
            object_version: nil,
            object_date: nil,
            objects: [],
            search_help_version: nil,
            search_help_date: nil,
            search_helps: [],
            edit_mask_version: nil,
            edit_mask_date: nil,
            edit_masks: [],
            lookup_version: nil,
            lookup_date: nil,
            lookups: [],
            update_help_version: nil,
            update_help_date: nil,
            update_helps: [],
            validation_expression_version: nil,
            validation_expression_date: nil,
            validation_expressions: [],
            validation_external_version: nil,
            validation_external_date: nil,
            validation_externals: []

  @type t :: %__MODULE__{
          resource_id: resource_id(),
          standard_name: standard_name(),
          visible_name: visible_name(),
          description: description(),
          key_field: key_field(),
          class_count: class_count(),
          class_version: class_version(),
          class_date: class_date(),
          classes: [Class.t()],
          object_version: object_version(),
          object_date: object_date(),
          objects: [Object.t()],
          search_help_version: search_help_version(),
          search_help_date: search_help_date(),
          search_helps: [SearchHelp.t()],
          edit_mask_version: edit_mask_version(),
          edit_mask_date: edit_mask_date(),
          edit_masks: [EditMask.t()],
          lookup_version: lookup_version(),
          lookup_date: lookup_date(),
          lookups: [Lookup.t()],
          update_help_version: update_help_version(),
          update_help_date: update_help_date(),
          update_helps: [UpdateHelp.t()],
          validation_expression_version: validation_expression_version(),
          validation_expression_date: validation_expression_date(),
          validation_expressions: [ValidationExpression.t()],
          validation_external_version: validation_external_version(),
          validation_external_date: validation_external_date(),
          validation_externals: [ValidationExternal.t()]
        }

  @typedoc "The name which acts as a unique ID for this resource."
  @type resource_id :: String.t()

  @typedoc "The name of the resource.  This must be a well-known name if applicable."
  @type standard_name :: String.t()

  @typedoc "The user-visible name of the resource."
  @type visible_name :: String.t()

  @typedoc "A user-visible description of the resource."
  @type description :: String.t()

  @typedoc """
  The `SystemName` of the field that provides a unique `ResourceKey` for each element in this
  resource.  All classes within a resource must use the same `KeyField`.
  """
  @type key_field :: String.t()

  @typedoc """
  The number of classes in this resource.  There MUST be `ClassCount METADATA_CLASS` descriptions
  for the resource.  There MUST be at least one Class for each Resource.
  """
  @type class_count :: pos_integer()

  @typedoc """
  The latest version of the Class metadata for this Resource.  The version number is advisory
  only.
  """
  @type class_version :: String.t()

  @typedoc """
  The date on which the Class metadata for this Resource was last changed.  Clients MAY rely on
  this date for cache management.
  """
  @type class_date :: NaiveDateTime.t()

  @typedoc """
  The version of the Object metaata for this Resource.  The version number is advisory only.  A
  `nil` version indicates no Object metadata is available for this Resource.
  """
  @type object_version :: String.t() | nil

  @typedoc """
  The date on which the Object metadata for this Resource was last changed.  Clients MAY rely on
  this date for cache management.  A `nil` date indicates no Object metadata is available for this
  Resource.
  """
  @type object_date :: String.t() | nil

  @typedoc """
  The version of the SearchHelp metadata for this Resource.  The version number is advisory only.
  A `nil` version indicates no SearchHelp is available for this Resource.
  """
  @type search_help_version :: String.t() | nil

  @typedoc """
  The date on which the SearchHelp metadata for this Resource was last changed.  Clients MAY rely
  on this date for cache management.  A `nil` date indicates no SearchHelp is available for this
  Resource.
  """
  @type search_help_date :: NaiveDateTime.t() | nil

  @typedoc """
  The version of the EditMask metadata for this Resource.  The version number is advisory only.  A
  `nil` version indicates no EditMask is available for this Resource.
  """
  @type edit_mask_version :: String.t() | nil

  @typedoc """
  The date on which the EditMask metadata for this Resource was last changed.  Clients MAY rely on
  this date for cache management.  A `nil` date indicates no EditMask is available for this
  Resource.
  """
  @type edit_mask_date :: NaiveDateTime.t() | nil

  @typedoc """
  The version of the Lookup metadata for this Resource.  The version number is advisory only.  A
  `nil` version indicates no Lookup is available for this Resource.
  """
  @type lookup_version :: String.t() | nil

  @typedoc """
  The date on which the Lookup metadata for this Resource was last changed.  Clients MAY rely on
  this date for cache management.  A `nil` date indicates no Lookup is available for this
  Resource.
  """
  @type lookup_date :: NaiveDateTime.t() | nil

  @typedoc """
  The version of the UpdateHelp metadata for this Resource.  The version number is advisory only.
  A `nil` version indicates no UpdateHelp is available for this Resource.
  """
  @type update_help_version :: String.t() | nil

  @typedoc """
  The date on which the UpdateHelp metadata for this Resource was last changed.  Clients MAY rely
  on this date for cache management.  A `nil` date indicates no UpdateHelp is available for this
  Resource.
  """
  @type update_help_date :: NaiveDateTime.t() | nil

  @typedoc """
  The version of the ValidationExpression metadata for this Resource.  The version number is
  advisory only.  A `nil` version indicates no ValidationExpression is available for this
  Resource.
  """
  @type validation_expression_version :: String.t() | nil

  @typedoc """
  The date on which the ValidationExpression metaata for this Resource was last changed.  Clients
  MAY rely on this date for cache management.  A `nil` date indicates no ValidationExpression is
  available for this Resource.
  """
  @type validation_expression_date :: NaiveDateTime.t() | nil

  @typedoc """
  The version of the ValidationExternal metadata for this Resource.  The version number is
  advisory only.  A `nil` version indicates no ValidationExternal is available for this Resource.
  """
  @type validation_external_version :: String.t() | nil

  @typedoc """
  The date on which the ValidationExternal metadata for this Resource was last changed.  Clients
  MAY rely on this date for cache management.  A `nil` date indicates no ValidationExternal is
  available for this Resource.
  """
  @type validation_external_date :: NaiveDateTime.t() | nil
end
