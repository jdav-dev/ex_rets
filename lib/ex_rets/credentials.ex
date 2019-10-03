defmodule ExRets.Credentials do
  @type t :: %__MODULE__{
          mls_id: atom(),
          login_uri: URI.t(),
          username: String.t(),
          password: String.t(),
          user_agent: String.t(),
          rets_version: String.t()
        }

  @derive {Inspect, only: [:mls_id, :login_uri, :rets_version]}
  @enforce_keys [:mls_id, :login_uri, :username, :password]
  defstruct mls_id: nil,
            login_uri: nil,
            username: nil,
            password: nil,
            user_agent: nil,
            rets_version: "RETS/1.8"
end
