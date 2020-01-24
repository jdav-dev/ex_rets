defmodule ExRets.RetsResponse do
  @moduledoc """
  The parsed response of a RETS request.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.LoginResponse
  alias ExRets.LogoutResponse
  alias ExRets.SearchResponse

  @typedoc "Parsed response of a RETS request."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          reply_code: reply_code(),
          reply_text: reply_text(),
          response: response()
        }

  defstruct reply_code: 0, reply_text: nil, response: nil

  @typedoc """
  Included to provide a mechanism to pass additional information to the client in the event that
  the request is processed OK but some condition still exist that may require an action by the
  client.

  A value of '0' indicates success.
  """
  @typedoc since: "0.1.0"
  @type reply_code :: non_neg_integer()

  @typedoc "Human-readable meaning of the `t:reply_code/0`"
  @typedoc since: "0.1.0"
  @type reply_text :: String.t()

  @typedoc "Main content of the RETS response."
  @typedoc since: "0.1.0"
  @type response :: LoginResponse.t() | LogoutResponse.t() | SearchResponse.t()
end
