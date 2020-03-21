defmodule ExRets.Metadata do
  @moduledoc since: "0.2.0"

  alias ExRets.BaseXmlParser
  alias ExRets.CompactDelimiter
  alias ExRets.CompactRecord
  alias ExRets.HttpClient
  alias ExRets.Metadata.Filter
  alias ExRets.Metadata.ForeignKey
  alias ExRets.Metadata.Resource
  alias ExRets.Metadata.Resource.Class
  alias ExRets.RetsResponse
  alias ExRets.XmlParser

  @behaviour XmlParser

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

  @doc since: "0.2.0"
  def parse(stream, http_client_implementation) do
    event_state = %{
      characters: [],
      delimiter: "\t",
      element: nil,
      rets_response: %RetsResponse{response: %__MODULE__{}}
    }

    event_fun_chain = RetsResponse.xmerl_event_fun(&event_fun/3)

    with {:ok, %{rets_response: rets_response}} <-
           BaseXmlParser.parse(stream, event_fun_chain, event_state, http_client_implementation) do
      metadata = rets_response.response
      metadata = %__MODULE__{metadata | resources: Enum.reverse(metadata.resources)}
      rets_response = %RetsResponse{rets_response | response: metadata}
      {:ok, rets_response}
    end
  end

  # defp xmerl_event_fun(next) do
  # end

  defp event_fun({:startElement, _, 'METADATA-SYSTEM', _, attributes}, _, state) do
    Enum.reduce(attributes, state, fn
      {_, _, 'Version', value}, acc ->
        version = to_string(value)
        put_in(acc.rets_response.response.version, version)

      {_, _, 'Date', value}, acc ->
        date =
          case value |> to_string() |> NaiveDateTime.from_iso8601() do
            {:ok, datetime} -> datetime
            _ -> value
          end

        put_in(acc.rets_response.response.date, date)

      _, acc ->
        acc
    end)
  end

  defp event_fun({:startElement, _, 'SYSTEM', _, attributes}, _, state) do
    Enum.reduce(attributes, state, fn
      {_, _, 'SystemID', value}, acc ->
        system_id = to_string(value)
        put_in(acc.rets_response.response.system_id, system_id)

      {_, _, 'SystemDescription', value}, acc ->
        system_description = to_string(value)
        put_in(acc.rets_response.response.system_description, system_description)

      {_, _, 'TimeZoneOffset', value}, acc ->
        time_zone_offset = to_string(value)
        put_in(acc.rets_response.response.time_zone_offset, time_zone_offset)

      {_, _, 'MetadataID', value}, acc ->
        metadata_id = to_string(value)
        put_in(acc.rets_response.response.metadata_id, metadata_id)

      _, acc ->
        acc
    end)
  end

  defp event_fun({:startElement, _, 'METADATA-RESOURCE', _, attributes}, _, state) do
    Enum.reduce(attributes, state, fn
      {_, _, 'Version', value}, acc ->
        resource_version = to_string(value)
        put_in(acc.rets_response.response.resource_version, resource_version)

      {_, _, 'Date', value}, acc ->
        resource_date =
          case value |> to_string() |> NaiveDateTime.from_iso8601() do
            {:ok, datetime} -> datetime
            _ -> value
          end

        put_in(acc.rets_response.response.resource_date, resource_date)

      _, acc ->
        acc
    end)
  end

  # defp event_fun({:startElement, _, 'Class', _, _}, _, %{element: %Resource{} = resource} = state) do
  #   put_in(state.element, {resource, %Class{}})
  # end

  defp event_fun({:startElement, _, _name, _, _attributes}, _, state) do
    put_in(state.characters, [])
  end

  defp event_fun({:characters, characters}, _, state) do
    put_in(state.characters, [characters | state.characters])
  end

  defp event_fun({:endElement, _, 'COMMENTS', _}, _, state) do
    comments =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")

    put_in(state.rets_response.response.comments, comments)
  end

  defp event_fun({:endElement, _, 'ResourceVersion', _}, _, state) do
    resource_version =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")

    put_in(state.rets_response.response.resource_version, resource_version)
  end

  defp event_fun({:endElement, _, 'ResourceDate', _}, _, state) do
    value =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")

    resource_date =
      case value |> String.trim() |> NaiveDateTime.from_iso8601() do
        {:ok, datetime} -> datetime
        _ -> value
      end

    put_in(state.rets_response.response.resource_date, resource_date)
  end

  defp event_fun({:endElement, _, 'ForeignKeyVersion', _}, _, state) do
    foreign_key_version =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")

    put_in(state.rets_response.response.foreign_key_version, foreign_key_version)
  end

  defp event_fun({:endElement, _, 'ForeignKeyDate', _}, _, state) do
    value =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")

    foreign_key_date =
      case value |> String.trim() |> NaiveDateTime.from_iso8601() do
        {:ok, datetime} -> datetime
        _ -> value
      end

    put_in(state.rets_response.response.foreign_key_date, foreign_key_date)
  end

  defp event_fun({:endElement, _, 'FilterVersion', _}, _, state) do
    filter_version =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")

    put_in(state.rets_response.response.filter_version, filter_version)
  end

  defp event_fun({:endElement, _, 'FilterDate', _}, _, state) do
    value =
      state.characters
      |> Enum.reverse()
      |> Enum.join("")

    filter_date =
      case value |> String.trim() |> NaiveDateTime.from_iso8601() do
        {:ok, datetime} -> datetime
        _ -> value
      end

    put_in(state.rets_response.response.filter_date, filter_date)
  end

  # defp event_fun(
  #        {:endElement, _, 'Class', _},
  #        _,
  #        %{element: {%Resource{} = resource, %Class{} = class}} = state
  #      ) do
  #   resource = put_in(resource.classes, [class | resource.classes])
  #   put_in(state.element, resource)
  # end

  defp event_fun(_event, _, state), do: state

  @impl XmlParser
  def start_element("METADATA", _attributes) do
    :skip
  end

  def start_element("METADATA-SYSTEM", attributes) do
    metadata = parse_attributes(attributes)
    {:ok, metadata}
  end

  def start_element(_, _) do
    :skip
  end

  defp parse_attributes(attributes) do
    Enum.reduce(attributes, %__MODULE__{}, fn
      {"Version", version}, acc ->
        put_in(acc.version, version)

      {"Date", value}, acc ->
        date =
          case NaiveDateTime.from_iso8601(value) do
            {:ok, datetime} -> datetime
            _ -> value
          end

        put_in(acc.date, date)

      _, acc ->
        acc
    end)
  end
end
