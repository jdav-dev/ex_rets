defmodule ExRets.CompactDelimiter do
  @moduledoc """
  A delimiter that separates fields in a compact record.
  """
  @moduledoc since: "0.1.0"

  @typedoc "Decoded delimiter value."
  @typedoc since: "0.1.0"
  @type t :: String.t()

  @typedoc "Raw delimiter value returned as part of a compact response."
  @typedoc since: "0.1.0"
  @type octet :: String.t()

  @doc """
  Decodes a delimiter value from the octet returned as part of a compact response.

  ## Examples

      iex> ExRets.CompactDelimiter.decode("09")
      {:ok, "\\t"}

      iex> ExRets.CompactDelimiter.decode("9")
      {:ok, "\\t"}

      iex> ExRets.CompactDelimiter.decode("invalid")
      :error
  """
  @doc since: "0.1.0"
  @spec decode(octet()) :: {:ok, t()} | :error
  def decode(octet) when is_binary(octet) do
    octet
    |> pad_odd_length_octets()
    |> Base.decode16(case: :mixed)
  end

  defp pad_odd_length_octets(octet) do
    octet_length = String.length(octet)

    case rem(octet_length, 2) do
      1 -> String.pad_leading(octet, octet_length + 1, "0")
      _ -> octet
    end
  end
end
