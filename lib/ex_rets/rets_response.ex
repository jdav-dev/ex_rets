defmodule ExRets.RetsResponse do
  alias ExRets.ParsedXml

  @type t :: %__MODULE__{
          reply_code: non_neg_integer(),
          reply_text: String.t(),
          response: String.t()
        }

  @enforce_keys [:reply_text, :response]
  defstruct reply_code: 0, reply_text: nil, response: nil

  def from_xml(%ParsedXml{name: :RETS, attributes: attributes, elements: elements}) do
    %__MODULE__{
      reply_code: String.to_integer(attributes[:ReplyCode]),
      reply_text: attributes[:ReplyText],
      response: elements
    }
  end
end
