defmodule ExRets.SearchResponse do
  alias ExRets.RetsResponse

  @type t :: %__MODULE__{
          count: non_neg_integer(),
          columns: [String.t()],
          rows: [String.t()]
        }

  defstruct count: nil, columns: [], rows: []

  def from_rets_response(%RetsResponse{response: response}) do
    count = get_count(response)
    delimiter = get_delimiter(response)
    columns = get_columns(response, delimiter)
    rows = get_datas(response, delimiter)

    %__MODULE__{count: count, columns: columns, rows: rows}
  end

  defp get_count(response) do
    count_string =
      response
      |> Enum.find(%{}, &(&1.name == :COUNT))
      |> Map.get(:attributes, %{})
      |> Map.get(:Records, "")

    case Integer.parse(count_string) do
      {count, _} -> count
      _ -> nil
    end
  end

  defp get_delimiter(response) do
    delimiter_octet =
      response
      |> Enum.find(%{}, &(&1.name == :DELIMITER))
      |> Map.get(:attributes, %{})
      |> Map.get(:value, "08")
      |> String.to_integer()

    <<delimiter_octet>>
  end

  defp get_columns(response, delimiter) do
    response
    |> Enum.find(%{}, &(&1.name == :COLUMNS))
    |> Map.get(:elements, %{})
    |> List.first()
    |> String.split(delimiter)
  end

  defp get_datas(response, delimiter) do
    response
    |> Stream.filter(&(&1.name == :DATA))
    |> Stream.map(&Map.get(&1, :elements))
    |> Stream.map(&List.first/1)
    |> Enum.map(&String.split(&1, delimiter))
  end
end
