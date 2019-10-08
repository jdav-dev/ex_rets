defmodule ExRets.CompactFormat.Delimiter do
  @type t :: String.t()

  @spec decode(value :: String.t()) :: {:ok, t()} | :error
  def decode(value) when is_binary(value) do
    value
    |> pad_odd_length_values()
    |> Base.decode16(case: :mixed)
  end

  defp pad_odd_length_values(value) do
    value_length = String.length(value)

    case rem(value_length, 2) do
      1 -> String.pad_leading(value, value_length + 1, "0")
      _ -> value
    end
  end
end
