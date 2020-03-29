defmodule ExRets.Metadata.Resource.Class.Field do
  import ExRets.StringParsers
  import ExRets.Xml.Schema

  defstruct [
    :metadata_entry_id,
    :system_name,
    :standard_name,
    :long_name,
    :db_name,
    :short_name,
    :maximum_length,
    :data_type,
    :precision,
    :searchable,
    :interpretation,
    :alignment,
    :use_separator,
    :edit_mask_id,
    :lookup_name,
    :max_select,
    :units,
    :index,
    :minumum,
    :maximum,
    :default,
    :required,
    :search_help_id,
    :unique,
    :mod_timestamp,
    :foreign_key_name,
    :foreign_field,
    :in_key_index,
    :filter_parent_field,
    :default_search_order,
    :case
  ]

  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          system_name: system_name(),
          standard_name: standard_name(),
          long_name: long_name(),
          db_name: db_name(),
          short_name: short_name(),
          maximum_length: maximum_length(),
          data_type: data_type(),
          precision: precision(),
          searchable: searchable(),
          interpretation: interpretation(),
          alignment: alignment(),
          use_separator: use_separator(),
          edit_mask_id: edit_mask_id(),
          lookup_name: lookup_name(),
          max_select: max_select(),
          units: units(),
          index: index(),
          minumum: minumum(),
          maximum: maximum(),
          default: default(),
          required: required(),
          search_help_id: search_help_id(),
          unique: unique(),
          mod_timestamp: mod_timestamp(),
          foreign_key_name: foreign_key_name(),
          foreign_field: foreign_field(),
          in_key_index: in_key_index(),
          filter_parent_field: filter_parent_field(),
          default_search_order: default_search_order(),
          case: case()
        }

  @typedoc """
  A value that never changes as long as the semantic definition of this field remains unchanged.
  In particular, it should be managed so as to allow the client to detect changes to the
  `SystemName`.
  """
  @type metadata_entry_id :: String.t()

  @typedoc """
  The name of the field as it is known to the native server.  The system name MUST be unique
  within the Table.
  """
  @type system_name :: String.t()

  @typedoc "The name of the field as it is known in the Real Estate Transaction XML DTD."
  @type standard_name :: String.t()

  @typedoc """
  The name of the field as it is known to the user.  This is a localizable, human-readable string.
  Use of this field is implementation-defined; it is expected that clients will use this value as
  a title for this datum when it appears on a report.
  """
  @type long_name :: String.t()

  @typedoc """
  A short name that can be used as a database field name.  This name may not start with a number
  nor can it be an ANSI-SQL92 reserved word.  This value can be used by a client as the name of an
  internal database field, so servers should attempt to provide a value for this field that is
  unique within the table.
  """
  @type db_name :: String.t()

  @typedoc """
  An abbreviated field name that is also localizable and human-readable.  Use of this field is
  implementation-defined.  It is expected that clients will use this field in human-interface
  elements such as pick lists.
  """
  @type short_name :: String.t()

  @typedoc """
  The maximum possible character length after all Transport layer encoding.  Transport layer
  encoding includes both HTTP and XML based encoding, but does not include RETS Lookup Value to
  Lookup Long Value encoding.
  """
  @type maximum_length :: pos_integer()

  @typedoc """
  Data type of the field.  Possible values include:

    * `:boolean` - A truth-value, stored using TRUE and FALSE.  That is 1 for true and 0 for
      false.
    * `:character` - An arbitrary sequence of printable characters.
    * `:date` - A date in full-date format.
    * `:date_time` - A date and time in RETSDATETIME format.
    * `:time` - A time
    * `:tiny` - A signed numeric value that can be stored in no more than 8 bits.
    * `:small` - A signed numeric value that can be stored in no more than 16 bits.
    * `:int` - A signed numeric value that can be stored in no more than 32 bits.
    * `:long` - A signed numeric value that can be stored in no more than 64 bits.
    * `:decimal` - A decimal value that contains a decimal point (see t:precision/0).
  """
  @type data_type ::
          :boolean
          | :character
          | :date
          | :date_time
          | :time
          | :tiny
          | :small
          | :int
          | :long
          | :decimal

  @typedoc "The number of digits to the right of the decimal point when formatted. Applies to
  `:decimal` fields only."
  @type precision :: non_neg_integer() | nil

  @typedoc "When true, indicates that the field is searchable."
  @type searchable :: boolean()

  @typedoc """
  Additional instruction on interpreting a field value:

    * `:number` - An arbitrary number.
    * `:currency` - A number representing a currency value.
    * `:lookup` - A value that should be looked up in the Lookup Table.  This is a single
      selection type lookup (e.g. `STATUS`).  This interpretation is also valid for Boolean data
      types, in which case the `LookupType` specified by the `LookupName` entry MUST contain
      exactly two elements, one with a `Value` of 0, and the other with a `Value` of 1.
    * `:lookup_multi` - A value that should be looked up in the Lookup Table. This is a
      multiple-selection type lookup (e.g. `FEATURES`) where the character strings representing
      each selection are separated by commas.  The character strings MAY be quoted text following
      the rules for Value of LookupType.
    * `:uri` - An arbitrary URI or URL that is fully qualified and that an application will be
      able to successfully link to.
  """
  @type interpretation :: :number | :currency | :lookup | :lookup_multi | :uri | nil

  @typedoc """
  Suggestion for how to display the value:

    * `:left` - The value MAY be displayed left aligned.
    * `:right` - The value MAY be displayed right aligned.
    * `:center` - The value MAY be centered in its field when displayed.
    * `:justify` - The value MAY be justified within its field when displayed.
  """
  @type alignment :: :left | :right | :center | :justify

  @typedoc """
  When `true`, indicates that the numeric value MAY be displayed with a thousands separator.
  """
  @type use_separator :: boolean()

  @typedoc """
  For each `RETSNAME`, the name of the `METADATA-EDITMASK` EditMaskID containing the edit mask
  expression for this field.  Multiple masks are permitted.
  """
  @type edit_mask_id :: [String.t()]

  @typedoc """
  The name of the `METADATA-LOOKUP` containing the lookup data for this field.  Required if
  Interpretation is Lookup or LookupMulti.
  """
  @type lookup_name :: String.t()

  @typedoc """
  This field is required if Interpretation is `LookupMulti`. This value indicates the maximum
  number of entries that may be selected in the lookup.
  """
  @type max_select :: integer()

  @typedoc "Unit of measure."
  @type units :: :feet | :meters | :sq_ft | :sq_meters | :acres | :hectares

  @typedoc """
  When `true`, indicates that this field is part of an index.  The client MAY use this information
  to help the user create faster queries.
  """
  @type index :: boolean()

  @typedoc "The minimum value that may be stored in a field (applies to `:numeric` fields only)."
  @type minumum :: integer()

  @typedoc "The maximum value that may be stored in a field (applies to `:numeric` fields only)."
  @type maximum :: integer()

  @typedoc """
  The order that fields should appear in a default one-line search result.  Fields that should not
  appear in the default one-line format should have a value of 0.  Fields that should never be
  visible to the user should have a value of -1.
  """
  @type default :: integer()

  @typedoc """
  A non-zero value indicates the field is required when searching.  This value should be
  sequential starting with one. If multiple fields share the same value, then one of the fields
  with the same value is required (e.g. City = 1 & ZipCode = 1 implies that the user is required
  to include either City or ZipCode in their query).
  """
  @type required :: non_neg_integer()

  @typedoc "The name of the entry in the `METADATA-SEARCH_HELP` table."
  @type search_help_id :: String.t()

  @typedoc """
  When `true`, indicates that this field is a unique identifier for the record that itis part of.
  """
  @type unique :: boolean()

  @typedoc """
  When `true`, indicates that changes to this field update the class's `ClassTimeStamp` field.
  """
  @type mod_timestamp :: boolean()

  @typedoc """
  When not `nil`, indicates that this field is normally populated via a foreign key.  The value is
  the ForeignKeyID from the `METADATA-FOREIGN_KEYS` table.
  """
  @type foreign_key_name :: String.t() | nil

  @typedoc "The `SystemName` from the child record accessed via the specified foreign key."
  @type foreign_field :: String.t()

  @typedoc """
  When `true`, indicates that this field may be included in the Select argument of a Search to
  suppress normal Limit behavior.
  """
  @type in_key_index :: boolean()

  @typedoc """
  Specifies that values allowed in this field are limited by a Lookup filter, using the contents
  of the field named here as ParentValue.  FilterParentField may only be specified with fields
  that have a LookupName, where the named Lookup has a non-empty FilterID.
  """
  @type filter_parent_field :: String.t()

  @typedoc """
  The order that fields should appear in a default search screen that is excuted in order to give
  the user a list of existing records to select from.  Fields that should not appear in the
  default search screen should have a value of `0`.  Fields that should never be visible to the
  user should have a value of `-1`.
  """
  @type default_search_order :: integer()

  @typedoc """
  Applicable when the field has a data type of Character.  A value that indicates that the server
  will store the data with the specified case.  This allows a client to automatically convert data
  in these fields to the correct case.

    * `:upper` - The data is stored on the server as upper case.  A client should convert values
      in this field to upper case for both searches and updates.  Servers MUST perform a case
      insensitive search.
    * `:lower` - The data is stored on the server as lower case. A client should convert values in
      this field to lower case for both searches and updates.  Servers MUST perform a case
      insensitive search.
    * `:exact` - The data is stored on the server as entered by the user.  The server MUST perform
      a case sensitive search.
    * `:mixed` - The data is stored on the server as entered by the user. The server MUST perform
      a case insensitive search.
  """
  @type case :: :upper | :lower | :exact | :mixed

  def standard_xml_schema do
    root "Table", %__MODULE__{} do
      element "MetadataEntryID" do
        text :metadata_entry_id, transform: &empty_string_to_nil/1
      end

      element "SystemName" do
        text :system_name, transform: &empty_string_to_nil/1
      end

      element "StandardName" do
        text :standard_name, transform: &empty_string_to_nil/1
      end

      element "LongName" do
        text :long_name, transform: &empty_string_to_nil/1
      end

      element "DBName" do
        text :db_name, transform: &empty_string_to_nil/1
      end

      element "ShortName" do
        text :short_name, transform: &empty_string_to_nil/1
      end

      element "MaximumLength" do
        text :maximum_length, transform: &parse_integer/1
      end

      element "DataType" do
        text :data_type, transform: &parse_data_type/1
      end

      element "Precision" do
        text :precision, transform: &parse_integer/1
      end

      element "Searchable" do
        text :searchable, transform: &parse_boolean/1
      end

      element "Interpretation" do
        text :interpretation, transform: &parse_interpretation/1
      end

      element "Alignment" do
        text :alignment, transform: &parse_alignment/1
      end

      element "UseSeparator" do
        text :use_separator, transform: &parse_boolean/1
      end

      element "EditMaskID" do
        text :edit_mask_id, transform: &empty_string_to_nil/1
      end

      element "LookupName" do
        text :lookup_name, transform: &empty_string_to_nil/1
      end

      element "MaxSelect" do
        text :max_select, transform: &parse_integer/1
      end

      element "Units" do
        text :units, transform: &parse_units/1
      end

      element "Index" do
        text :index, transform: &parse_boolean/1
      end

      element "Minimum" do
        text :minimum, transform: &parse_integer/1
      end

      element "Maximum" do
        text :maximum, transform: &parse_integer/1
      end

      element "Default" do
        text :default, transform: &parse_integer/1
      end

      element "Required" do
        text :required, transform: &parse_integer/1
      end

      element "SearchHelpID" do
        text :search_help_id, transform: &empty_string_to_nil/1
      end

      element "Unique" do
        text :unique, transform: &parse_boolean/1
      end

      element "ModTimeStamp" do
        text :mod_time_stamp, transform: &parse_boolean/1
      end

      element "ForeignKeyName" do
        text :foreign_key_name, transform: &empty_string_to_nil/1
      end

      element "ForeignField" do
        text :foreign_field, transform: &empty_string_to_nil/1
      end

      element "InKeyIndex" do
        text :in_key_index, transform: &parse_boolean/1
      end

      element "FilterParentField" do
        text :filter_parent_field, transform: &empty_string_to_nil/1
      end

      element "DefaultSearchOrder" do
        text :default_search_order, transform: &parse_integer/1
      end

      element "Case" do
        text :case, transform: &parse_case/1
      end
    end
  end

  defp parse_data_type("Boolean"), do: :boolean
  defp parse_data_type("Character"), do: :character
  defp parse_data_type("Date"), do: :date
  defp parse_data_type("DateTime"), do: :date_time
  defp parse_data_type("Time"), do: :time
  defp parse_data_type("Tiny"), do: :tiny
  defp parse_data_type("Small"), do: :small
  defp parse_data_type("Int"), do: :int
  defp parse_data_type("Long"), do: :long
  defp parse_data_type("Decimal"), do: :decimal
  defp parse_data_type(value), do: value

  defp parse_interpretation("Number"), do: :number
  defp parse_interpretation("Currency"), do: :currency
  defp parse_interpretation("Lookup"), do: :lookup
  defp parse_interpretation("LookupMulti"), do: :lookup_multi
  defp parse_interpretation("URI"), do: :uri
  defp parse_interpretation(value), do: value

  defp parse_alignment("Left"), do: :left
  defp parse_alignment("Right"), do: :right
  defp parse_alignment("Center"), do: :center
  defp parse_alignment("Justify"), do: :justify
  defp parse_alignment(value), do: value

  defp parse_units("Feet"), do: :feet
  defp parse_units("Meters"), do: :meters
  defp parse_units("SqFt"), do: :sq_ft
  defp parse_units("SqMeters"), do: :sq_meters
  defp parse_units("Acres"), do: :acres
  defp parse_units("Hectares"), do: :hectares
  defp parse_units(value), do: value

  defp parse_case("UPPER"), do: :upper
  defp parse_case("LOWER"), do: :lower
  defp parse_case("EXACT"), do: :exact
  defp parse_case("MIXED"), do: :mixed
  defp parse_case(value), do: value
end
