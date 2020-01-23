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
          user_id: user_id(),
          user_class: user_class(),
          user_level: user_level(),
          agent_code: agent_code(),
          broker_code: broker_code(),
          broker_branch: broker_branch(),
          member_name: member_name(),
          metadata_version: metadata_version(),
          metadata_timestamp: metadata_timestamp(),
          min_metadata_timestamp: min_metadata_timestamp(),
          metadata_id: metadata_id(),
          balance: balance(),
          timeout_seconds: timeout_seconds(),
          password_expiration: password_expiration(),
          warn_password_expiration_days: warn_password_expiration_days(),
          office_list: office_list(),
          standard_names_version: standard_names_version(),
          vendor_name: vendor_name(),
          server_product_name: server_product_name(),
          server_product_version: server_product_version(),
          operator_name: operator_name(),
          role_name: role_name(),
          support_contact_information: support_contact_information()
        }

  @typedoc """
  ID of the signed in user.
  """
  @typedoc since: "0.1.0"
  @type user_id :: String.t()

  @typedoc """
  Used in the validation routines of the Update transaction.  Implementation dependent and may not
  exist on some systems.
  """
  @typedoc since: "0.1.0"
  @type user_class :: String.t()

  @typedoc """
  Used in the validation routines of the Update transaction.  Implementation dependent and may not
  exist on some systems.
  """
  @typedoc since: "0.1.0"
  @type user_level :: non_neg_integer()

  @typedoc """
  Code that is stored in the property records for the listing agent, selling agent, etc.
  """
  @typedoc since: "0.1.0"
  @type agent_code :: String.t()

  @typedoc "Used in the validation routines of the Update transaction."
  @typedoc since: "0.1.0"
  @type broker_code :: String.t() | nil

  @typedoc "Used in the validation routines of the Update transaction."
  @typedoc since: "0.1.0"
  @type broker_branch :: String.t() | nil

  @typedoc """
  Member's full name (display name) as it is to appear on any printed output; for example
  "Jane T. Row".
  """
  @typedoc since: "0.1.0"
  @type member_name :: String.t() | nil

  @typedoc "Most current version of the metadata that is available on the server."
  @typedoc since: "0.1.0"
  @type metadata_version :: String.t() | nil

  @typedoc "Timestamp associated with the current version of metadata on the server."
  @typedoc since: "0.1.0"
  @type metadata_timestamp :: NaiveDateTime.t() | nil

  @typedoc "Earliest version of the metadata that the server will support."
  @typedoc since: "0.1.0"
  @type min_metadata_timestamp :: NaiveDateTime.t() | nil

  @typedoc "Persistent ID associated with the metadata applied to the current user session."
  @typedoc since: "0.1.0"
  @type metadata_id :: String.t() | nil

  @typedoc "User-readable indication of the money balance in the account."
  @typedoc since: "0.1.0"
  @type balance :: String.t() | nil

  @typedoc "Number of seconds after a transaction that a session will remain active."
  @typedoc since: "0.1.0"
  @type timeout_seconds :: integer() | nil

  @typedoc "Date that the current user password becomes invalid."
  @typedoc since: "0.1.0"
  @type password_expiration :: NaiveDateTime.t() | nil

  @typedoc """
  Number of days before the expiration date that the user should be warned of the upcoming
  password expiration.  A value of "-1" indicates that the password expiration is disabled.
  """
  @typedoc since: "0.1.0"
  @type warn_password_expiration_days :: integer() | nil

  @typedoc "Enumeration of the offices to which the server will permit login."
  @typedoc since: "0.1.0"
  @type office_list :: [String.t()] | nil

  @typedoc "Version of StandardNames that the server supports."
  @typedoc since: "0.1.0"
  @type standard_names_version :: String.t() | nil

  @typedoc "Name of the server product vendor."
  @typedoc since: "0.1.0"
  @type vendor_name :: String.t() | nil

  @typedoc "Name of the server product provided by the vendor."
  @typedoc since: "0.1.0"
  @type server_product_name :: String.t() | nil

  @typedoc "Version of the server product."
  @typedoc since: "0.1.0"
  @type server_product_version :: String.t() | nil

  @typedoc "Name of the MLS or Association operating the system."
  @typedoc since: "0.1.0"
  @type operator_name :: String.t() | nil

  @typedoc "Name of the role restriction where the metadata may be restricted."
  @typedoc since: "0.1.0"
  @type role_name :: String.t() | nil

  @typedoc "Free text that provides a contact email, phone, or website for development support."
  @typedoc since: "0.1.0"
  @type support_contact_information :: String.t() | nil

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
      office_list: get_csv_field(params, "officelist"),
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
    |> Enum.map(&String.trim/1)
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

  defp get_csv_field(params, key) do
    if value = params[key] do
      value
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
    end
  end
end
