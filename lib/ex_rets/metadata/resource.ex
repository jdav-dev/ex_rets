defmodule ExRets.Metadata.Resource do
  alias ExRets.Metadata.Resource.Class
  alias ExRets.Metadata.Resource.EditMask
  alias ExRets.Metadata.Resource.Lookup
  alias ExRets.Metadata.Resource.Object
  alias ExRets.Metadata.Resource.SearchHelp
  alias ExRets.Metadata.Resource.UpdateHelp
  alias ExRets.Metadata.Resource.ValidationExternal
  alias ExRets.Metadata.Resource.ValidationExpression

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

  # @doc false
  # @doc since: "0.2.0"
  # def xmerl_event_fun(next) do
  #   fn put_in
  # end

  defp event_fun({:startElement, _, 'Resource', _, _}, _, state) do
    put_in(state.element, %__MODULE__{})
  end

  defp event_fun({:endElement, _, 'ResourceID', _}, _, %{element: %__MODULE__{}} = state) do
    resource_id = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.resource_id, resource_id)
  end

  defp event_fun({:endElement, _, 'StandardName', _}, _, %{element: %__MODULE__{}} = state) do
    standard_name = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.standard_name, standard_name)
  end

  defp event_fun({:endElement, _, 'VisibleName', _}, _, %{element: %__MODULE__{}} = state) do
    visible_name = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.visible_name, visible_name)
  end

  defp event_fun({:endElement, _, 'Description', _}, _, %{element: %__MODULE__{}} = state) do
    description = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.description, description)
  end

  defp event_fun({:endElement, _, 'KeyField', _}, _, %{element: %__MODULE__{}} = state) do
    key_field = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.key_field, key_field)
  end

  defp event_fun({:endElement, _, 'ClassCount', _}, _, %{element: %__MODULE__{}} = state) do
    value =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")
      |> String.trim()

    class_count =
      case Integer.parse(value) do
        {class_count, _} -> class_count
        _ -> value
      end

    put_in(state.element.class_count, class_count)
  end

  defp event_fun({:endElement, _, 'ClassVersion', _}, _, %{element: %__MODULE__{}} = state) do
    class_version = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.class_version, class_version)
  end

  defp event_fun({:endElement, _, 'ClassDate', _}, _, %{element: %__MODULE__{}} = state) do
    value = state.characters |> Enum.reverse() |> Enum.join("")

    class_date =
      case NaiveDateTime.from_iso8601(value) do
        {:ok, class_date} -> class_date
        _ -> value
      end

    put_in(state.element.class_date, class_date)
  end

  defp event_fun({:endElement, _, 'ObjectVersion', _}, _, %{element: %__MODULE__{}} = state) do
    object_version = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.object_version, object_version)
  end

  defp event_fun({:endElement, _, 'ObjectDate', _}, _, %{element: %__MODULE__{}} = state) do
    value = state.characters |> Enum.reverse() |> Enum.join("")

    object_date =
      case NaiveDateTime.from_iso8601(value) do
        {:ok, object_date} -> object_date
        _ -> value
      end

    put_in(state.element.object_date, object_date)
  end

  defp event_fun({:endElement, _, 'SearchHelpVersion', _}, _, %{element: %__MODULE__{}} = state) do
    search_help_version = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.search_help_version, search_help_version)
  end

  defp event_fun({:endElement, _, 'SearchHelpDate', _}, _, %{element: %__MODULE__{}} = state) do
    value = state.characters |> Enum.reverse() |> Enum.join("")

    search_help_date =
      case NaiveDateTime.from_iso8601(value) do
        {:ok, search_help_date} -> search_help_date
        _ -> value
      end

    put_in(state.element.search_help_date, search_help_date)
  end

  defp event_fun({:endElement, _, 'EditMaskVersion', _}, _, %{element: %__MODULE__{}} = state) do
    edit_mask_version = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.edit_mask_version, edit_mask_version)
  end

  defp event_fun({:endElement, _, 'EditMaskDate', _}, _, %{element: %__MODULE__{}} = state) do
    value = state.characters |> Enum.reverse() |> Enum.join("")

    edit_mask_date =
      case NaiveDateTime.from_iso8601(value) do
        {:ok, edit_mask_date} -> edit_mask_date
        _ -> value
      end

    put_in(state.element.edit_mask_date, edit_mask_date)
  end

  defp event_fun({:endElement, _, 'LookupVersion', _}, _, %{element: %__MODULE__{}} = state) do
    lookup_version = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.lookup_version, lookup_version)
  end

  defp event_fun({:endElement, _, 'LookupDate', _}, _, %{element: %__MODULE__{}} = state) do
    value = state.characters |> Enum.reverse() |> Enum.join("")

    lookup_date =
      case NaiveDateTime.from_iso8601(value) do
        {:ok, lookup_date} -> lookup_date
        _ -> value
      end

    put_in(state.element.lookup_date, lookup_date)
  end

  defp event_fun({:endElement, _, 'UpdateHelpVersion', _}, _, %{element: %__MODULE__{}} = state) do
    update_help_version = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.update_help_version, update_help_version)
  end

  defp event_fun({:endElement, _, 'UpdateHelpDate', _}, _, %{element: %__MODULE__{}} = state) do
    value = state.characters |> Enum.reverse() |> Enum.join("")

    update_help_date =
      case NaiveDateTime.from_iso8601(value) do
        {:ok, update_help_date} -> update_help_date
        _ -> value
      end

    put_in(state.element.update_help_date, update_help_date)
  end

  defp event_fun(
         {:endElement, _, 'ValidationExpressionVersion', _},
         _,
         %{element: %__MODULE__{}} = state
       ) do
    validation_expression_version = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.validation_expression_version, validation_expression_version)
  end

  defp event_fun(
         {:endElement, _, 'ValidationExpressionDate', _},
         _,
         %{element: %__MODULE__{}} = state
       ) do
    value = state.characters |> Enum.reverse() |> Enum.join("")

    validation_expression_date =
      case NaiveDateTime.from_iso8601(value) do
        {:ok, validation_expression_date} -> validation_expression_date
        _ -> value
      end

    put_in(state.element.validation_expression_date, validation_expression_date)
  end

  defp event_fun(
         {:endElement, _, 'ValidationExternalVersion', _},
         _,
         %{element: %__MODULE__{}} = state
       ) do
    validation_external_version = state.characters |> Enum.reverse() |> Enum.join("")
    put_in(state.element.validation_external_version, validation_external_version)
  end

  defp event_fun(
         {:endElement, _, 'ValidationExternalDate', _},
         _,
         %{element: %__MODULE__{}} = state
       ) do
    value = state.characters |> Enum.reverse() |> Enum.join("")

    validation_external_date =
      case NaiveDateTime.from_iso8601(value) do
        {:ok, validation_external_date} -> validation_external_date
        _ -> value
      end

    put_in(state.element.validation_external_date, validation_external_date)
  end

  defp event_fun(
         {:endElement, _, 'Resource', _},
         _,
         %{element: %__MODULE__{} = resource} = state
       ) do
    resource = put_in(resource.classes, Enum.reverse(resource.classes))

    put_in(state.rets_response.response.resources, [
      resource | state.rets_response.response.resources
    ])
  end
end
