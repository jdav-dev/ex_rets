defmodule ExRets.GetMetadataArguments do
  @moduledoc since: "0.2.0"

  defstruct format: :standard_xml, type: "METADATA-SYSTEM", id: "*"

  @typedoc since: "0.2.0"
  @type t :: %__MODULE__{
          type: type(),
          id: id(),
          format: format()
        }

  @typedoc """
  The type of metadata being requested.  The Type MUST begin with METADATA and MAY be one of the
  defined metadata types.  Defaults to `"METADATA-SYSTEM"`.
  """
  @typedoc since: "0.2.0"
  @type type :: String.t()

  @typedoc """
  This identifier can be used to restrict requests to the Type metadata contained within specific
  instances of higher levels.  If the last metadata-id is 0 (zero), then the request is for all
  Type metadata contained within that level; if the last metadata-id is "*", then the request is
  for all Type metadata contained within that level and all metadata Types contained within the
  requested Type.  Defaults to `"*"`
  """
  @typedoc since: "0.2.0"
  @type id :: String.t()

  @typedoc """
  Format of the metadata response.  Defaults to `:standard_xml`.

    * `:compact` - A table descriptor, field list <COLUMNS> followed by a delimited set of the
      data fields.
    * `:standard_xml` - An XML presentation of the data in the format defined by the RETS Metadata
      XML DTD.
  """
  @typedoc since: "0.2.0"
  @type format :: :compact | :standard_xml

  @doc """
  Encodes get metadata arguments `t:t/0` into a query string.

  ## Examples

      iex> get_metadata_arguments = %ExRets.GetMetadataArguments{
      ...>   type: "METADATA-SYSTEM",
      ...>   id: "*",
      ...>   format: :compact
      ...> }
      iex> ExRets.GetMetadataArguments.encode_query(get_metadata_arguments)
      "Format=COMPACT&ID=%2A&Type=METADATA-SYSTEM"
  """
  @doc since: "0.1.0"
  @spec encode_query(get_metadata_arguments :: t()) :: String.t()
  def encode_query(%__MODULE__{} = get_metadata_arguments) do
    get_metadata_arguments
    |> Map.from_struct()
    |> Enum.into(%{}, &format_key_and_value/1)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> URI.encode_query()
  end

  defp format_key_and_value({:type, type}), do: {"Type", type}
  defp format_key_and_value({:id, id}), do: {"ID", id}
  defp format_key_and_value({:format, :compact}), do: {"Format", "COMPACT"}
  defp format_key_and_value({:format, _}), do: {"Format", "STANDARD-XML"}
end
