defmodule ExRets.RetsResponse do
  @type t :: %__MODULE__{
          reply_code: non_neg_integer(),
          reply_text: String.t(),
          response: String.t()
        }

  defstruct reply_code: 0, reply_text: nil, response: nil
end
