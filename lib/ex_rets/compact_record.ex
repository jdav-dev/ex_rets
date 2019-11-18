defmodule ExRets.CompactRecord do
  @moduledoc """
  Compact records are sequences of fields separated by a delimiter.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.CompactDelimiter

  @typedoc "Parsed list of fields."
  @typedoc since: "0.1.0"
  @type t :: [String.t()]

  @typedoc "Options for decoding compact data."
  @typedoc since: "0.1.0"
  @type decode_opts :: [decode_opt()]

  @typedoc "Option for decoding compact data."
  @typedoc since: "0.1.0"
  @type decode_opt :: {:delimiter, CompactDelimiter.t()}

  @doc """
  Parses a compact `record` string into a list of strings.

  ## Options

    * `:delimiter` - string that separates the compact `record` fields.  Defaults to `\\t`.

  ## Examples

      iex> ExRets.CompactRecord.decode("\\tListingKey\\tModificationTimestamp\\t")
      ["ListingKey", "ModificationTimestamp"]

      iex> ExRets.CompactRecord.decode("\\nListingKey\\nModificationTimestamp\\n", delimiter: "\\n")
      ["ListingKey", "ModificationTimestamp"]
  """
  @doc since: "0.1.0"
  @spec decode(record :: String.t(), decode_opts()) :: [String.t()]
  def decode(record, opts \\ []) when is_binary(record) and is_list(opts) do
    delimiter = opts[:delimiter] || "\t"

    split_data = String.split(record, delimiter)
    start_index = 1
    amount = length(split_data) - start_index - 1

    Enum.slice(split_data, start_index, amount)
  end
end
