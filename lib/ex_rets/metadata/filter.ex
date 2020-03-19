defmodule ExRets.Metadata.Filter do
  alias ExRets.Metadata.Filter.FilterType

  defstruct [
    :filter_id,
    :parent_resource,
    :parent_lookup_name,
    :child_resource,
    :child_lookup_name,
    :not_shown_by_default,
    :filter_type_version,
    :filter_type_date,
    :filter_types
  ]

  @type t :: %__MODULE__{
          filter_id: filter_id(),
          parent_resource: parent_resource(),
          parent_lookup_name: parent_lookup_name(),
          child_resource: child_resource(),
          child_lookup_name: child_lookup_name(),
          not_shown_by_default: not_shown_by_default(),
          filter_type_version: filter_type_version(),
          filter_type_date: filter_type_date(),
          filter_types: [FilterType.t()]
        }

  @typedoc "The name which acts as a unique ID for this filter."
  @type filter_id :: String.t()

  @typedoc "ResourceID of the parent lookup."
  @type parent_resource :: String.t()

  @typedoc "LookupName of the parent lookup."
  @type parent_lookup_name :: String.t()

  @typedoc "ResourceID of the child lookup."
  @type child_resource :: String.t()

  @typedoc "LookupName of the child lookup."
  @type child_lookup_name :: String.t()

  @typedoc """
  If true the server will by default not include the FilterValue data of this filter in any
  metadata request, unless unless specifically asked to using the LookupFilter argument in
  GetMetadata.
  """
  @type not_shown_by_default :: boolean()

  @typedoc """
  This is the version of the FilterType metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @type filter_type_version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @type filter_type_date :: NaiveDateTime.t()
end
