defmodule ExRets.SearchArguments do
  @moduledoc """
  Arguments for a RETS Search Transaction.
  """
  @moduledoc since: "0.1.0"

  @enforce_keys [:search_type, :class]
  defstruct search_type: nil,
            class: nil,
            count: :no_record_count,
            format: "COMPACT-DECODED",
            limit: "NONE",
            offset: 1,
            select: nil,
            restricted_indicator: nil,
            standard_names: false,
            payload: nil,
            query: nil,
            query_type: "DMQL2"

  @typedoc "Arguments for a RETS Search Transaction."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          search_type: search_type(),
          class: class(),
          count: count(),
          format: format(),
          limit: limit(),
          offset: offset(),
          select: select(),
          restricted_indicator: restricted_indicator(),
          standard_names: standard_names(),
          payload: payload(),
          query: query(),
          query_type: query_type()
        }

  @typedoc "Specifies the resource to search.  Required."
  @typedoc since: "0.1.0"
  @type search_type :: String.t()

  @typedoc "Specifies the class of the resource to search.  Required."
  @typedoc since: "0.1.0"
  @type class :: String.t()

  @typedoc """
  Controls whether the server's response includes a count.

  Possible values:

  * `:no_record_count` - no record count returned
  * `:include_record_count` - record-count is returned in addition to the data
  * `:only_record_count` - only a record-count is returned; no data is returned
  """
  @typedoc since: "0.1.0"
  @type count :: :no_record_count | :include_record_count | :only_record_count

  @typedoc """
  Selects one of the three supported data return formats for the query response.

  Possible values:

  * COMPACT
  * COMPACT-DECODED
  * STANDARD-XML
  """
  @typedoc since: "0.1.0"
  @type format :: String.t()

  @typedoc """
  Requests the server to apply or suspend a limit on the number of records returned in the search.
  """
  @typedoc since: "0.1.0"
  @type limit :: integer() | String.t()

  @typedoc """
  Retrieve records beginning with the record number indicated, with a value of 1 indicating to
  start with the first record.
  """
  @typedoc since: "0.1.0"
  @type offset :: non_neg_integer()

  @typedoc """
  A comma-separated list of fields for the server to return.
  """
  @typedoc since: "0.1.0"
  @type select :: String.t() | nil

  @typedoc """
  Used in place of withheld field values.
  """
  @typedoc since: "0.1.0"
  @type restricted_indicator :: String.t() | nil

  @typedoc """
  Specifies whether to use standard names or system names.

  This argument affects to all names used in `search_type`, `class`, `query`, and `select`
  arguments.

  Possible values:

  * `false` - system names
  * `true` - standard names
  """
  @typedoc since: "0.1.0"
  @type standard_names :: boolean()

  @typedoc """
  Request a specific XML format for the return set.

  Only set `payload` OR `format` and optionally `select`.
  """
  @typedoc since: "0.1.0"
  @type payload :: String.t() | nil

  @typedoc """
  Query as specified by the language denoted in `query_type`.
  """
  @typedoc since: "0.1.0"
  @type query :: String.t() | nil

  @typedoc """
  Designates the query language used in `query`.
  """
  @typedoc since: "0.1.0"
  @type query_type :: String.t() | nil

  @doc """
  Encodes search arguments `t:t/0` into a query string.

  ## Examples

      iex> search_arguments = %ExRets.SearchArguments{
      ...>   search_type: "Property",
      ...>   class: "Residential"
      ...> }
      iex> ExRets.SearchArguments.encode_query(search_arguments)
      "Class=Residential&Count=0&Format=COMPACT-DECODED&Limit=NONE&Offset=1&QueryType=DMQL2&SearchType=Property&StandardNames=0"
  """
  @doc since: "0.1.0"
  @spec encode_query(search_arguments :: t()) :: String.t()
  def encode_query(%__MODULE__{} = search_arguments) do
    search_arguments
    |> Map.from_struct()
    |> Enum.into(%{}, &format_key_and_value/1)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> URI.encode_query()
  end

  defp format_key_and_value({:count, :no_record_count}), do: {"Count", 0}
  defp format_key_and_value({:count, :include_record_count}), do: {"Count", 1}
  defp format_key_and_value({:count, :only_record_count}), do: {"Count", 2}
  defp format_key_and_value({:count, _}), do: {"Count", 0}
  defp format_key_and_value({:standard_names, false}), do: {"StandardNames", 0}
  defp format_key_and_value({:standard_names, true}), do: {"StandardNames", 1}
  defp format_key_and_value({k, v}), do: {to_camel_case(k), v}

  defp to_camel_case(atom) do
    atom
    |> to_string()
    |> String.split("_")
    |> Enum.map_join(&String.capitalize/1)
  end
end
