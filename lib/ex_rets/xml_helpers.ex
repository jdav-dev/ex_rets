defmodule ExRets.XmlHelpers do
  def empty_string_to_nil(value) do
    case value do
      "" -> nil
      _ -> value
    end
  end

  def parse_integer(value) do
    case Integer.parse(value) do
      {integer, _} -> integer
      :error -> value
    end
  end

  def parse_naive_date_time(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, naive_date_time} -> naive_date_time
      {:error, _reason} -> value
    end
  end
end
