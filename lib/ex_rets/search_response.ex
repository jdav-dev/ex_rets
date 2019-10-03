defmodule ExRets.SearchResponse do
  alias ExRets.RetsResponse

  @type t :: %__MODULE__{
          count: non_neg_integer(),
          results: [%{optional(String.t()) => String.t()}]
        }

  defstruct count: nil, results: []

  def from_rets_response(%RetsResponse{response: response}) do
    count = get_count(response)
    delimiter = get_delimiter(response)
    columns = get_columns(response, delimiter)
    datas = get_datas(response, delimiter)

    results =
      datas
      |> pair_datas_with_columns(columns)
      |> filter_empty_data()
      |> convert_datas_to_maps()

    %__MODULE__{count: count, results: results}
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

  defp pair_datas_with_columns(datas, columns) do
    Stream.map(datas, &Enum.zip(columns, &1))
  end

  defp filter_empty_data(stream) do
    stream
    |> Stream.map(&Enum.reject(&1, fn {_, v} -> is_nil(v) or v == "" end))
    |> Stream.reject(&(&1 == %{}))
  end

  defp convert_datas_to_maps(stream) do
    Enum.map(stream, &Enum.into(&1, %{}))
  end
end
