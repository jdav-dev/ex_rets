defmodule ExRets.LoginResponse do
  alias ExRets.{CapabilityUris, RetsResponse, SessionInformation}

  @type t :: %__MODULE__{
          session_information: SessionInformation.t(),
          capability_uris: CapabilityUris.t()
        }

  defstruct session_information: %SessionInformation{}, capability_uris: %CapabilityUris{}

  def from_rets_response(login_uri, %RetsResponse{} = rets_response) do
    %__MODULE__{
      session_information: SessionInformation.from_rets_response(rets_response),
      capability_uris: CapabilityUris.from_rets_response(login_uri, rets_response)
    }
  end
end
