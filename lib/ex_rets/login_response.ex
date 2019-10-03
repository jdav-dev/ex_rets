defmodule ExRets.LoginResponse do
  alias ExRets.{CapabilityUris, RetsResponse, SessionInformation}

  @type t :: %__MODULE__{
          session_information: SessionInformation.t(),
          capability_uris: CapabilityUris.t()
        }

  defstruct session_information: %SessionInformation{}, capability_uris: %CapabilityUris{}

  def from_rets_response(login_uri, %RetsResponse{response: response}) do
    key_value_body = get_key_value_body(response)

    %__MODULE__{
      session_information: SessionInformation.from_rets_response(key_value_body),
      capability_uris: CapabilityUris.from_rets_response(key_value_body, login_uri)
    }
  end

  defp get_key_value_body(response) do
    response
    |> Enum.find(%{}, &(&1.name == :"RETS-RESPONSE"))
    |> Map.get(:elements, [])
    |> List.first()
  end
end
