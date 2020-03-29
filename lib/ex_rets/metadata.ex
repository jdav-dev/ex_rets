defmodule ExRets.Metadata do
  @moduledoc since: "0.2.0"

  import ExRets.StringParsers
  import ExRets.Xml.Schema

  alias ExRets.Metadata.Filter
  alias ExRets.Metadata.ForeignKey
  alias ExRets.Metadata.Resource
  alias ExRets.RetsResponse

  defstruct version: nil,
            date: nil,
            system_id: nil,
            system_description: nil,
            time_zone_offset: nil,
            metadata_id: nil,
            comments: nil,
            resource_version: nil,
            resource_date: nil,
            resources: [],
            foreign_key_version: nil,
            foreign_key_date: nil,
            foreign_keys: [],
            filter_version: nil,
            filter_date: nil,
            filters: []

  @typedoc since: "0.2.0"
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
  @typedoc since: "0.2.0"
  @type version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @typedoc since: "0.2.0"
  @type date :: NaiveDateTime.t()

  @typedoc "An identifier for the system"
  @typedoc since: "0.2.0"
  @type system_id :: String.t()

  @typedoc "An implementation defined description of the system"
  @typedoc since: "0.2.0"
  @type system_description :: String.t()

  @typedoc """
  The Time Zone Offset is the time offset of the server relative to UTC.  The server MAY provide
  the TimeZoneOffset to assist in correctly calculating date and time values for requests to this
  server.  Any server that provides the TimeZoneOffset value in System Metadata MUST adhere to
  this value when responding to requests. Client applications SHOULD use this value to calculate
  the correct date and time criteria for requests.
  """
  @typedoc since: "0.2.0"
  @type time_zone_offset :: String.t()

  @typedoc "An optional identifier for catching role-based metadata."
  @typedoc since: "0.2.0"
  @type metadata_id :: String.t()

  @typedoc """
  Optional comments about the system.  The context where the field contains characters may require
  those characters are escaped by other rules like entity encoding.
  """
  @typedoc since: "0.2.0"
  @type comments :: String.t()

  @typedoc "The version of the set of Resource Metadata"
  @typedoc since: "0.2.0"
  @type resource_version :: String.t()

  @typedoc "The date of the version of the set of Resource Metadata"
  @typedoc since: "0.2.0"
  @type resource_date :: NaiveDateTime.t()

  @typedoc "The version of the set of ForeignKey Metadata"
  @typedoc since: "0.2.0"
  @type foreign_key_version :: String.t()

  @typedoc "The date of the version of the set of ForeignKey Metadata"
  @typedoc since: "0.2.0"
  @type foreign_key_date :: NaiveDateTime.t()

  @typedoc "The version of the set of Filter Metadata"
  @typedoc since: "0.2.0"
  @type filter_version :: String.t()

  @typedoc "The date of teh version of the set of Filter Metadata"
  @typedoc since: "0.2.0"
  @type filter_date :: NaiveDateTime.t()

  def standard_xml_schema do
    RetsResponse.schema(
      root "METADATA", %__MODULE__{} do
        element "METADATA-SYSTEM" do
          attribute "Version", :version, transform: &empty_string_to_nil/1
          attribute "Date", :date, transform: &parse_naive_date_time/1

          element "SYSTEM" do
            attribute "SystemID", :system_id, transform: &empty_string_to_nil/1

            attribute "SystemDescription", :system_description,
              transform: &parse_naive_date_time/1

            attribute "TimeZoneOffset", :time_zone_offset, transform: &empty_string_to_nil/1
            attribute "MetadataID", :metadata_id, transform: &empty_string_to_nil/1

            element "COMMENTS" do
              text :comments, transform: &empty_string_to_nil/1
            end

            element "ResourceVersion" do
              text :resource_version, transform: &empty_string_to_nil/1
            end

            element "ResourceDate" do
              text :resource_date, transform: &parse_naive_date_time/1
            end

            element "METADATA-RESOURCE" do
              attribute "Version", :resource_version, transform: &empty_string_to_nil/1
              attribute "Date", :resource_date, transform: &parse_naive_date_time/1
              child_element :resources, Resource.standard_xml_schema(), list: true
            end

            element "ForeignKeyVersion" do
              text :foreign_key_version, transform: &empty_string_to_nil/1
            end

            element "ForeignKeyDate" do
              text :foreign_key_date, transform: &parse_naive_date_time/1
            end

            element "METADATA-FOREIGN_KEY" do
              attribute "Version", :foreign_key_version, transform: &empty_string_to_nil/1
              attribute "Date", :foreign_key_date, transform: &parse_naive_date_time/1
              child_element :foreign_keys, ForeignKey.standard_xml_schema(), list: true
            end

            element "FilterVersion" do
              text :filter_version, transform: &empty_string_to_nil/1
            end

            element "FilterDate" do
              text :filter_date, transform: &parse_naive_date_time/1
            end

            element "METADATA-FILTER" do
              attribute "Version", :filter_version, transform: &empty_string_to_nil/1
              attribute "Date", :filter_date, transform: &parse_naive_date_time/1
              child_element :filters, Filter.standard_xml_schema(), list: true
            end
          end
        end
      end
    )
  end
end
