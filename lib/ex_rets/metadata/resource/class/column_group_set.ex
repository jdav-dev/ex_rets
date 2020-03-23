defmodule ExRets.Metadata.Resource.Class.ColumnGroupSet do
  defstruct [
    :metadata_entry_id,
    :column_group_set_name,
    :column_group_set_parent,
    :sequence,
    :long_name,
    :short_name,
    :description,
    :column_group_name,
    :presentation_style,
    :url,
    :foreign_key_id
  ]

  @typedoc """
  A tree structure which should be used to render the data in any GUI system that is designed in
  order to satisfy the display requirements of an MLS.
  """
  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          column_group_set_name: column_group_set_name(),
          column_group_set_parent: column_group_set_parent(),
          sequence: sequence(),
          long_name: long_name(),
          short_name: short_name(),
          description: description(),
          column_group_name: column_group_name(),
          presentation_style: presentation_style(),
          url: url(),
          foreign_key_id: foreign_key_id()
        }

  @typedoc """
  A value that never changes as long as the semantic definition of this entry remains unchanged.
  In particular, it should be managed so as to allow the client to detect changes to the
  ColumnGroupSetName.
  """
  @type metadata_entry_id :: String.t()

  @typedoc "The name that uniquely identifies this Column Group Set within the Class."
  @type column_group_set_name :: String.t()

  @typedoc """
  The ColumnGroupSetName of the Parent Column Group Set.  If not specified, this Column Group Set
  is the top node in the tree.
  """
  @type column_group_set_parent :: String.t()

  @typedoc """
  The sequence that this Column Group Set is to be displayed in within its parent group.
  """
  @type sequence :: non_neg_integer()

  @typedoc """
  The name of the Column Group Set as it is known to the user.  This is a localizable,
  human-readable string.  Use of this field is implementation-defined; it is expected that clients
  will use this value as a title for this Column Group Set when it appears on a report.
  """
  @type long_name :: String.t()

  @typedoc """
  An abbreviated field name that is also localizable and human-readable.  Use of this field is
  implementation-defined; it is expected that clients will use this field in human-interface
  elements such as lookups.
  """
  @type short_name :: String.t()

  @typedoc """
  A brief description of the purpose for this Column Group Set.
  """
  @type description :: String.t()

  @typedoc """
  The name of the Column Group that is to be displayed in this Column Group Set.  If `nil`, this
  Column Group Set is to be treated as a node in the tree that displays no data.  The
  ColumnGroupName must exist in the Column Group metadata for this Class.
  """
  @type column_group_name :: String.t() | nil

  @typedoc """
  One of the following values:

    * `:edit` - Basic Edit Block displayed in PresentationColumns number of columns.
    * `:matrix` - Expected to be displayed using Normalization Grid.
    * `:list` - Show one record per row.
    * `:edit_list` - Show one record per row and allow the records to be added, edited and
      deleted.
    * `:gis_map_search` - Special Case: Can only have 2 columns in Column Group.  First column is
      Latitude and Second column is Longitude.  These columns are expected to be filled in with
      results from GIS Map Search.
    * `:url` - Indicates that this is to simply go to the specified URL, a ColumnGroup name MUST
      not be specified and a URL MUST be specified for this PresentationStyle.
  """
  @type presentation_style :: :edit | :matrix | :list | :edit_list | :gis_map_search | :url

  @typedoc """
  Indicates a URL that is to be accessed using this entry instead of a standard Column Group.  You
  may not specify a ColumnGroupName and a URL.  The URL may be formed with place-holders
  surrounded by the '[' and ']' characters so that a substitution for any valid SystemName within
  the class being displayed, Info Tokens from the Login Response or Validation Expression Special
  Operand Tokens.  To differentiate between SystemNames and tokens, an additional character '.' is
  used to surround the tokens.  Example:
  `[http://www.example.com/agent?Agent=[.AGENTCODE.]]&Listing=[ListingID]`
  """
  @type url :: String.t() | nil

  @typedoc """
  The identifier of the Foreign Key that is to be displayed in this ColumnGroupSet.  If specified,
  the ForeignKeyID MUST exist in the METADATA-FOREIGNKEY metadata and the Parent MUST be the
  Property and Class of this ColumnGroupSet.  When this is specified, it means that a multi-row
  block is expected to be displayed to the user within which he can Add, Edit or Delete records of
  the Child Resource and Class that is specified.  Furthermore, the ChildSystemName field should
  always be filled from data found in the ParentSystemName field to provide for a proper
  Master/Detail relationship.
  """
  @type foreign_key_id :: String.t()

  def parse_presentation_style("Edit"), do: :edit
  def parse_presentation_style("Matrix"), do: :matrix
  def parse_presentation_style("List"), do: :list
  def parse_presentation_style("Edit List"), do: :edit_list
  def parse_presentation_style("GIS Map Search"), do: :gis_map_search
  def parse_presentation_style("URL"), do: :url
  def parse_presentation_style(value), do: value
end
