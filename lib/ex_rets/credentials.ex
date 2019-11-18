defmodule ExRets.Credentials do
  @moduledoc """
  Login information required to begin a RETS session.
  """
  @moduledoc since: "0.1.0"

  @derive {Inspect, only: [:system_id, :login_uri, :rets_version]}
  defstruct system_id: nil,
            login_uri: nil,
            username: nil,
            password: nil,
            user_agent: nil,
            user_agent_password: nil,
            rets_version: "RETS/1.8"

  @typedoc "Login information required to begin a RETS session."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          system_id: atom(),
          login_uri: URI.t(),
          username: String.t(),
          password: String.t(),
          user_agent: String.t() | nil,
          user_agent_password: String.t() | nil,
          rets_version: String.t()
        }
end
