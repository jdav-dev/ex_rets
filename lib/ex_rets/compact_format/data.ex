defmodule ExRets.CompactFormat.Data do
  @type t :: [String.t()]

  @type options :: [option()]
  @type option :: {:delimiter, delimiter()}

  @type delimiter :: String.t()

  @spec parse(data :: String.t(), options()) :: t()
  def parse(data, opts \\ []) when is_binary(data) and is_list(opts) do
    delimiter = opts[:delimiter] || "\t"
    split_data = String.split(data, delimiter)
    length_split_data = length(split_data)
    start_index = if String.starts_with?(data, delimiter), do: 1, else: 0

    amount =
      if String.ends_with?(data, delimiter) do
        length_split_data - start_index - 1
      else
        length_split_data - start_index
      end

    Enum.slice(split_data, start_index, amount)
  end
end
