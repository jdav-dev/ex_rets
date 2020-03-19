defmodule ExRets.Metadata.Resource.Class.Update do
  alias ExRets.Metadata.Resource.Class.Update.UpdateType

  defstruct [
    :metadata_entry_id,
    :update_action,
    :description,
    :key_field,
    :update_type_version,
    :update_type_date,
    :update_types,
    :requires_begin
  ]

  @type t :: %__MODULE__{
          metadata_entry_id: metadata_entry_id(),
          update_action: update_action(),
          description: description(),
          key_field: key_field(),
          update_type_version: update_type_version(),
          update_type_date: update_type_date(),
          update_types: [UpdateType.t()],
          requires_begin: requires_begin()
        }

  @typedoc """
  A value that never changes so long as the semantic definition of this entry remains unchanged.
  """
  @type metadata_entry_id :: String.t()

  @typedoc """
  This identifies the nature of the update.  Some update types, such as changes to a property
  record (e.g. "Sell", "Back on Market"), will imply a set of business rules specific to the
  server.  However, where possible, the following standard type names should be used:

    * `:add` - Add a new record
    * `:clone` - Create a new record by copying an old record
    * `:change` - Change an existing record
    * `:delete` - Delete an existing record
    * `:begin_update` - MAY be requested before any other Update request to get the specified
      record's actual data and to put a lock on the record.  The server MAY lock the requested
      record until another Update for that record is requested.
    * `:cancel_update` - MUST be used after `BeginUpdate` if no other update is requested on the
      locked record.  It is not an error to request `CancelUpdate` on a record that is not locked.
    * `:show_locks` - Request to show which records are currently locked by this user.  The server
      MUST respond with a column-tag showing the `KeyField` and `Lock` in the `COMPACT-DATA`
      format containing one line for each locked record.  The `Lock` indicates that number of
      seconds before the record lock will expire.
  """
  @type update_action ::
          :add
          | :clone
          | :change
          | :delete
          | :begin_update
          | :cancel_update
          | :show_locks
          | String.t()

  @typedoc "A user visible description of the Update Type."
  @type description :: String.t()

  @typedoc """
  The SystemName of the field that must be used to retrieve an existing record for the update.
  """
  @type key_field :: String.t()

  @typedoc """
  The latest version of this Update Type metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme.  The version number is advisory only.
  """
  @type update_type_version :: String.t()

  @typedoc """
  The date on which any of the content of this Update Type was last changed.  Clients MAY rely on
  this date for cache management.
  """
  @type update_type_date :: NaiveDateTime.t()

  @typedoc """
  If this value is `true`, the BeginUpdate action MUST be called before this update action.
  """
  @type requires_begin :: boolean()
end
