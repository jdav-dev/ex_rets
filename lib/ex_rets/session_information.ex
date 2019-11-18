defmodule ExRets.SessionInformation do
  @moduledoc """
  Identity and parameter information.
  """
  @moduledoc since: "0.1.0"

  alias ExRets.LoginResponse

  defstruct [
    :user_id,
    :user_class,
    :user_level,
    :agent_code,
    :broker_code,
    :broker_branch,
    :member_name,
    :metadata_id,
    :metadata_version,
    :metadata_timestamp,
    :min_metadata_timestamp,
    :balance,
    :timeout_seconds,
    :password_expiration,
    :warn_password_expiration_days,
    :office_list,
    :standard_names_version,
    :vendor_name,
    :server_product_name,
    :server_product_version,
    :operator_name,
    :role_name,
    :support_contact_information
  ]

  @typedoc "Identity and parameter information."
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          user_id: String.t() | nil,
          user_class: String.t() | nil,
          user_level: integer() | nil,
          agent_code: String.t() | nil,
          broker_code: String.t() | nil,
          broker_branch: String.t() | nil,
          member_name: String.t() | nil,
          metadata_version: String.t() | nil,
          metadata_timestamp: NaiveDateTime.t() | nil,
          min_metadata_timestamp: NaiveDateTime.t() | nil,
          metadata_id: String.t() | nil,
          balance: String.t() | nil,
          timeout_seconds: integer() | nil,
          password_expiration: NaiveDateTime.t() | nil,
          warn_password_expiration_days: integer() | nil,
          office_list: String.t() | nil,
          standard_names_version: String.t() | nil,
          vendor_name: String.t() | nil,
          server_product_name: String.t() | nil,
          server_product_version: String.t() | nil,
          operator_name: String.t() | nil,
          role_name: String.t() | nil,
          support_contact_information: String.t() | nil
        }

  @doc """
  Parses session information returned as part of a login response.

  Attempts to parse data types into equivalent Elixir types, but will pass through invalid values
  as strings.

  ## Examples

      iex> ExRets.SessionInformation.parse("Info=USERID;Character;1")
      %ExRets.SessionInformation{user_id: "1"}

      iex> ExRets.SessionInformation.parse("Info=MetadataTimestamp;DateTime;2019-11-13T19:58:45Z")
      %ExRets.SessionInformation{metadata_timestamp: ~N[2019-11-13T19:58:45Z]}

      iex> ExRets.SessionInformation.parse("Info=MetadataTimestamp;DateTime;invalid")
      %ExRets.SessionInformation{metadata_timestamp: "invalid"}
  """
  @doc since: "0.1.0"
  @spec parse(LoginResponse.key_value_body()) :: t()
  def parse(key_value_body) when is_binary(key_value_body) do
    params =
      key_value_body
      |> parse_login_response()
      |> normalize_keys()

    %__MODULE__{
      user_id: params["userid"],
      user_class: params["userclass"],
      user_level: params["userlevel"],
      agent_code: params["agentcode"],
      broker_code: params["brokercode"],
      broker_branch: params["brokerbranch"],
      member_name: params["membername"],
      metadata_id: params["metadataid"],
      metadata_version: params["metadataversion"],
      metadata_timestamp: params["metadatatimestamp"],
      min_metadata_timestamp: params["minmetadatatimestamp"],
      balance: params["balance"],
      timeout_seconds: params["timeoutseconds"],
      password_expiration: params["passwordexpiration"],
      warn_password_expiration_days: params["warnpasswordexpirationdays"],
      office_list: params["officelist"],
      standard_names_version: params["standardnamesversion"],
      vendor_name: params["vendorname"],
      server_product_name: params["serverproductname"],
      server_product_version: params["serverproductversion"],
      operator_name: params["operatorname"],
      role_name: params["rolename"],
      support_contact_information: params["supportcontactinformation"]
    }
  end

  defp parse_login_response(key_value_body) do
    key_value_body
    |> String.split("\n")
    |> Enum.reduce(%{}, &map_response_arguments/2)
  end

  defp map_response_arguments("Info" <> info, acc) do
    trimmed_info =
      info
      |> String.trim()
      |> String.trim_leading("=")
      |> String.trim()

    case String.split(trimmed_info, ";") do
      [key, type, value] ->
        normalized_type = trim_and_downcase_string(type)
        parsed_value = parse_response_value(normalized_type, value)
        Map.put(acc, key, parsed_value)

      [key, value] ->
        Map.put(acc, key, value)

      _ ->
        acc
    end
  end

  defp map_response_arguments(_, acc) do
    acc
  end

  defp trim_and_downcase_string(string) do
    string
    |> String.trim()
    |> String.downcase()
  end

  defp parse_response_value("datetime", value) do
    case value |> String.trim() |> NaiveDateTime.from_iso8601() do
      {:ok, datetime} -> datetime
      _ -> value
    end
  end

  defp parse_response_value("int", value) do
    case value |> String.trim() |> Integer.parse() do
      {integer, _} -> integer
      _ -> value
    end
  end

  defp parse_response_value(_type, value) do
    String.trim(value)
  end

  defp normalize_keys(map) do
    Enum.into(map, %{}, fn {k, v} -> {trim_and_downcase_string(k), v} end)
  end
end
