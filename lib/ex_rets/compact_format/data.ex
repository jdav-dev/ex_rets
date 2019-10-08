defmodule ExRets.CompactFormat.Data do
  @type t :: [String.t()]

  @type options :: [option()]
  @type option :: {:delimiter, delimiter()}

  @type delimiter :: String.t()

  @spec parse(data :: String.t(), options()) :: t()
  def parse(data, opts \\ []) when is_binary(data) and is_list(opts) do
    delimiter = opts[:delimiter] || "\t"

    start_index = if String.starts_with?(data, delimiter), do: 1, else: 0
    length_data = String.length(data)

    amount =
      if String.ends_with?(data, delimiter) do
        length_data - start_index - 1
      else
        length_data - start_index
      end

    data
    |> String.split(delimiter)
    |> Enum.slice(start_index, amount)
  end
end
