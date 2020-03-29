defmodule ExRets.Metadata.Resource do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

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

  def standard_xml_schema do
    root "Resource", %__MODULE__{} do
      element "ResourceID" do
        text :resource_id, transform: &empty_string_to_nil/1
      end

      element "StandardName" do
        text :standard_name, transform: &empty_string_to_nil/1
      end

      element "VisibleName" do
        text :visible_name, transform: &empty_string_to_nil/1
      end

      element "Description" do
        text :description, transform: &empty_string_to_nil/1
      end

      element "KeyField" do
        text :key_field, transform: &empty_string_to_nil/1
      end

      element "ClassCount" do
        text :class_count, transform: &parse_integer/1
      end

      element "ClassVersion" do
        text :class_version, transform: &empty_string_to_nil/1
      end

      element "ClassDate" do
        text :class_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-CLASS" do
        attribute "Version", :class_version, transform: &empty_string_to_nil/1
        attribute "Date", :class_date, transform: &parse_naive_date_time/1
        child_element :classes, Class.standard_xml_schema(), list: true
      end

      element "ObjectVersion" do
        text :object_version, transform: &empty_string_to_nil/1
      end

      element "ObjectDate" do
        text :object_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-OBJECT" do
        attribute "Version", :object_version, transform: &empty_string_to_nil/1
        attribute "Date", :object_date, transform: &parse_naive_date_time/1
        child_element :objects, Object.standard_xml_schema(), list: true
      end

      element "SearchHelpVersion" do
        text :search_help_version, transform: &empty_string_to_nil/1
      end

      element "SearchHelpDate" do
        text :search_help_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-SEARCH_HELP" do
        attribute "Version", :search_help_version, transform: &empty_string_to_nil/1
        attribute "Date", :search_help_date, transform: &parse_naive_date_time/1
        child_element :search_helps, SearchHelp.standard_xml_schema(), list: true
      end

      element "EditMaskVersion" do
        text :edit_mask_version, transform: &empty_string_to_nil/1
      end

      element "EditMaskDate" do
        text :edit_mask_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-EDITMASK" do
        attribute "Version", :edit_mask_version, transform: &empty_string_to_nil/1
        attribute "Date", :edit_mask_date, transform: &parse_naive_date_time/1
        child_element :edit_masks, EditMask.standard_xml_schema(), list: true
      end

      element "LookupVersion" do
        text :lookup_version, transform: &empty_string_to_nil/1
      end

      element "LookupDate" do
        text :lookup_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-LOOKUP" do
        attribute "Version", :lookup_version, transform: &empty_string_to_nil/1
        attribute "Date", :lookup_date, transform: &parse_naive_date_time/1
        child_element :lookups, Lookup.standard_xml_schema(), list: true
      end

      element "UpdateHelpVersion" do
        text :update_help_version, transform: &empty_string_to_nil/1
      end

      element "UpdateHelpDate" do
        text :update_help_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-UPDATE_HELP" do
        attribute "Version", :update_help_version, transform: &empty_string_to_nil/1
        attribute "Date", :update_help_date, transform: &parse_naive_date_time/1
        child_element :update_helps, UpdateHelp.standard_xml_schema(), list: true
      end

      element "ValidationExpressionVersion" do
        text :validation_expression_version, transform: &empty_string_to_nil/1
      end

      element "ValidationExpressionDate" do
        text :validation_expression_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-VALIDATION_EXPRESSION" do
        attribute "Version", :validation_expression_version, transform: &empty_string_to_nil/1
        attribute "Date", :validation_expression_date, transform: &parse_naive_date_time/1

        child_element :validation_expressions, ValidationExpression.standard_xml_schema(),
          list: true
      end

      element "ValidationExternalVersion" do
        text :validation_external_version, transform: &empty_string_to_nil/1
      end

      element "ValidationExternalDate" do
        text :validation_external_date, transform: &parse_naive_date_time/1
      end

      element "METADATA-VALIDATION_EXTERNAL" do
        attribute "Version", :validation_external_version, transform: &empty_string_to_nil/1
        attribute "Date", :validation_external_date, transform: &parse_naive_date_time/1
        child_element :validation_externals, ValidationExternal.standard_xml_schema(), list: true
      end
    end
  end
end
