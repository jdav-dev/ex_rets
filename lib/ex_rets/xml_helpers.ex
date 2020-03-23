defmodule ExRets.XmlHelpers do
  def empty_string_to_nil(""), do: nil
  def empty_string_to_nil(value), do: value

  def parse_boolean("0"), do: false
  def parse_boolean("1"), do: true
  def parse_boolean(value), do: value

  def parse_integer(value) do
    case Integer.parse(value) do
      {integer, _} -> integer
      :error -> empty_string_to_nil(value)
    end
  end

  def parse_naive_date_time(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, naive_date_time} -> naive_date_time
      {:error, _reason} -> empty_string_to_nil(value)
    end
  end
end
