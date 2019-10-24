defmodule ExRets.Credentials do
  @type t :: %__MODULE__{
          system_id: atom(),
          login_uri: URI.t(),
          username: String.t(),
          password: String.t(),
          user_agent: String.t(),
          rets_version: String.t()
        }

  @derive {Inspect, only: [:system_id, :login_uri, :rets_version]}
  @enforce_keys [:system_id, :login_uri, :username, :password]
  defstruct system_id: nil,
            login_uri: nil,
            username: nil,
            password: nil,
            user_agent: nil,
            rets_version: "RETS/1.8"
end
