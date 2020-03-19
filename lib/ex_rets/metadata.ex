defmodule ExRets.Metadata do
  alias ExRets.Metadata.Filter
  alias ExRets.Metadata.ForeignKey
  alias ExRets.Metadata.Resource

  defstruct [
    :version,
    :date,
    :system_id,
    :system_description,
    :time_zone_offset,
    :metadata_id,
    :comments,
    :resource_version,
    :resource_date,
    :resources,
    :foreign_key_version,
    :foreign_key_date,
    :foreign_keys,
    :filter_version,
    :filter_date,
    :filters
  ]

  @type t :: %__MODULE__{
          system_id: system_id(),
          system_description: system_description(),
          time_zone_offset: time_zone_offset(),
          metadata_id: metadata_id(),
          comments: comments(),
          resource_version: resource_version(),
          resource_date: resource_date(),
          resources: [Resource.t()],
          foreign_key_version: foreign_key_version(),
          foreign_key_date: foreign_key_date(),
          foreign_keys: [ForeignKey.t()],
          filter_version: filter_version(),
          filter_date: filter_date(),
          filters: [Filter.t()]
        }

  @typedoc """
  This is the version of the System metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme. Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @type version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @type date :: NaiveDateTime.t()

  @typedoc "An identifier for the system"
  @type system_id :: String.t()

  @typedoc "An implementation defined description of the system"
  @type system_description :: String.t()

  @typedoc """
  The Time Zone Offset is the time offset of the server relative to UTC.  The server MAY provide
  the TimeZoneOffset to assist in correctly calculating date and time values for requests to this
  server.  Any server that provides the TimeZoneOffset value in System Metadata MUST adhere to
  this value when responding to requests. Client applications SHOULD use this value to calculate
  the correct date and time criteria for requests.
  """
  @type time_zone_offset :: String.t()

  @typedoc "An optional identifier for catching role-based metadata."
  @type metadata_id :: String.t()

  @typedoc """
  Optional comments about the system.  The context where the field contains characters may require
  those characters are escaped by other rules like entity encoding.
  """
  @type comments :: String.t()

  @typedoc "The version of the set of Resource Metadata"
  @type resource_version :: String.t()

  @typedoc "The date of the version of the set of Resource Metadata"
  @type resource_date :: NaiveDateTime.t()

  @typedoc "The version of the set of ForeignKey Metadata"
  @type foreign_key_version :: String.t()

  @typedoc "The date of the version of the set of ForeignKey Metadata"
  @type foreign_key_date :: NaiveDateTime.t()

  @typedoc "The version of the set of Filter Metadata"
  @type filter_version :: String.t()

  @typedoc "The date of teh version of the set of Filter Metadata"
  @type filter_date :: NaiveDateTime.t()
end
