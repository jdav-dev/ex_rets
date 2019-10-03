defmodule ExRets.ParsedXml do
  @type t :: %__MODULE__{
          name: atom(),
          attributes: %{optional(atom()) => String.t()},
          elements: [String.t() | __MODULE__.t()]
        }

  @enforce_keys [:name]
  defstruct name: nil, attributes: [], elements: []
end
