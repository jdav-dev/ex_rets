defmodule ExRets.SearchArguments do
  @type t :: %__MODULE__{
          search_type: String.t(),
          class: String.t(),
          count: 0 | 1 | 2,
          format: String.t(),
          limit: integer() | String.t(),
          offset: non_neg_integer(),
          select: String.t() | nil,
          restricted_indicator: String.t() | nil,
          standard_names: 0 | 1,
          payload: String.t() | nil,
          query: String.t() | nil,
          query_type: String.t()
        }

  @enforce_keys [:search_type, :class]
  defstruct search_type: nil,
            class: nil,
            count: 0,
            format: "COMPACT-DECODED",
            limit: "NONE",
            offset: 1,
            select: nil,
            restricted_indicator: nil,
            standard_names: 0,
            payload: nil,
            query: nil,
            query_type: "DMQL2"

  def encode_query(%__MODULE__{} = search_arguments) do
    search_arguments
    |> Map.from_struct()
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{}, fn {k, v} -> {to_camel_case(k), v} end)
    |> URI.encode_query()
  end

  defp to_camel_case(atom) do
    atom
    |> to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join()
  end
end
