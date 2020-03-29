defmodule ExRets.Metadata do
  @moduledoc since: "0.2.0"

  import ExRets.StringParsers
  import ExRets.Xml.Schema

  alias ExRets.Metadata.Filter
  alias ExRets.Metadata.Filter.FilterType
  alias ExRets.Metadata.ForeignKey
  alias ExRets.Metadata.Resource
  alias ExRets.Metadata.Resource.Class
  alias ExRets.Metadata.Resource.Class.ColumnGroup
  alias ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupControl
  alias ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupNormalization
  alias ExRets.Metadata.Resource.Class.ColumnGroup.ColumnGroupTable
  alias ExRets.Metadata.Resource.Class.ColumnGroupSet
  alias ExRets.Metadata.Resource.Class.Field
  alias ExRets.Metadata.Resource.Class.Update
  alias ExRets.Metadata.Resource.Class.Update.UpdateType
  alias ExRets.Metadata.Resource.EditMask
  alias ExRets.Metadata.Resource.Lookup
  alias ExRets.Metadata.Resource.Lookup.LookupType
  alias ExRets.Metadata.Resource.Object
  alias ExRets.Metadata.Resource.SearchHelp
  alias ExRets.Metadata.Resource.UpdateHelp
  alias ExRets.Metadata.Resource.ValidationExpression
  alias ExRets.Metadata.Resource.ValidationExternal
  alias ExRets.Metadata.Resource.ValidationExternal.ValidationExternalType
  alias ExRets.RetsResponse
  alias ExRets.Xml

  defstruct version: nil,
            date: nil,
            system_id: nil,
            system_description: nil,
            time_zone_offset: nil,
            metadata_id: nil,
            comments: nil,
            resource_version: nil,
            resource_date: nil,
            resources: [],
            foreign_key_version: nil,
            foreign_key_date: nil,
            foreign_keys: [],
            filter_version: nil,
            filter_date: nil,
            filters: []

  @typedoc since: "0.2.0"
  @type t :: %__MODULE__{
          system_id: system_id(),
          system_description: system_description(),
          time_zone_offset: time_zone_offset(),
          metadata_id: metadata_id(),
          comments: comments(),
          resource_version: resource_version(),
          resource_date: resource_date(),
          resources: [Resource.t()],
          foreign_key_version: foreign_key_version(),
          foreign_key_date: foreign_key_date(),
          foreign_keys: [ForeignKey.t()],
          filter_version: filter_version(),
          filter_date: filter_date(),
          filters: [Filter.t()]
        }

  @typedoc """
  This is the version of the System metadata.  The convention used is a
  "<major>.<minor>.<release>" numbering scheme. Every time any contained metadata element changes
  the version number MUST be increased.
  """
  @typedoc since: "0.2.0"
  @type version :: String.t()

  @typedoc "The latest change date of any contained metadata."
  @typedoc since: "0.2.0"
  @type date :: NaiveDateTime.t()

  @typedoc "An identifier for the system"
  @typedoc since: "0.2.0"
  @type system_id :: String.t()

  @typedoc "An implementation defined description of the system"
  @typedoc since: "0.2.0"
  @type system_description :: String.t()

  @typedoc """
  The Time Zone Offset is the time offset of the server relative to UTC.  The server MAY provide
  the TimeZoneOffset to assist in correctly calculating date and time values for requests to this
  server.  Any server that provides the TimeZoneOffset value in System Metadata MUST adhere to
  this value when responding to requests. Client applications SHOULD use this value to calculate
  the correct date and time criteria for requests.
  """
  @typedoc since: "0.2.0"
  @type time_zone_offset :: String.t()

  @typedoc "An optional identifier for catching role-based metadata."
  @typedoc since: "0.2.0"
  @type metadata_id :: String.t()

  @typedoc """
  Optional comments about the system.  The context where the field contains characters may require
  those characters are escaped by other rules like entity encoding.
  """
  @typedoc since: "0.2.0"
  @type comments :: String.t()

  @typedoc "The version of the set of Resource Metadata"
  @typedoc since: "0.2.0"
  @type resource_version :: String.t()

  @typedoc "The date of the version of the set of Resource Metadata"
  @typedoc since: "0.2.0"
  @type resource_date :: NaiveDateTime.t()

  @typedoc "The version of the set of ForeignKey Metadata"
  @typedoc since: "0.2.0"
  @type foreign_key_version :: String.t()

  @typedoc "The date of the version of the set of ForeignKey Metadata"
  @typedoc since: "0.2.0"
  @type foreign_key_date :: NaiveDateTime.t()

  @typedoc "The version of the set of Filter Metadata"
  @typedoc since: "0.2.0"
  @type filter_version :: String.t()

  @typedoc "The date of teh version of the set of Filter Metadata"
  @typedoc since: "0.2.0"
  @type filter_date :: NaiveDateTime.t()

  def parse(stream, http_client_implementation) do
    Xml.parse(standard_xml_schema(), stream, http_client_implementation)
  end

  defp standard_xml_schema do
    RetsResponse.schema(
      root "METADATA", %__MODULE__{} do
        element "METADATA-SYSTEM" do
          attribute "Version", :version, transform: &empty_string_to_nil/1
          attribute "Date", :date, transform: &parse_naive_date_time/1

          element "SYSTEM" do
            attribute "SystemID", :system_id, transform: &empty_string_to_nil/1

            attribute "SystemDescription", :system_description,
              transform: &parse_naive_date_time/1

            attribute "TimeZoneOffset", :time_zone_offset, transform: &empty_string_to_nil/1
            attribute "MetadataID", :metadata_id, transform: &empty_string_to_nil/1

            element "COMMENTS" do
              text :comments, transform: &empty_string_to_nil/1
            end

            element "ResourceVersion" do
              text :resource_version, transform: &empty_string_to_nil/1
            end

            element "ResourceDate" do
              text :resource_date, transform: &parse_naive_date_time/1
            end

            element "METADATA-RESOURCE" do
              attribute "Version", :resource_version, transform: &empty_string_to_nil/1
              attribute "Date", :resource_date, transform: &parse_naive_date_time/1

              element "Resource", :resources, %Resource{}, list: true do
                element "ResourceID" do
                  text :resource_id, transform: &empty_string_to_nil/1
                end

                element "StandardName" do
                  text :standard_name, transform: &empty_string_to_nil/1
                end

                element "VisibleName" do
                  text :visible_name, transform: &empty_string_to_nil/1
                end

                element "Description" do
                  text :description, transform: &empty_string_to_nil/1
                end

                element "KeyField" do
                  text :key_field, transform: &empty_string_to_nil/1
                end

                element "ClassCount" do
                  text :class_count, transform: &parse_integer/1
                end

                element "ClassVersion" do
                  text :class_version, transform: &empty_string_to_nil/1
                end

                element "ClassDate" do
                  text :class_date, transform: &parse_naive_date_time/1
                end

                element "METADATA-CLASS" do
                  attribute "Version", :class_version, transform: &empty_string_to_nil/1
                  attribute "Date", :class_date, transform: &parse_naive_date_time/1

                  element "Class", :classes, %Class{}, list: true do
                    element "ClassName" do
                      text :class_name, transform: &empty_string_to_nil/1
                    end

                    element "StandardName" do
                      text :standard_name, transform: &empty_string_to_nil/1
                    end

                    element "VisibleName" do
                      text :visible_name, transform: &empty_string_to_nil/1
                    end

                    element "Description" do
                      text :description, transform: &empty_string_to_nil/1
                    end

                    element "TableVersion" do
                      text :field_version, transform: &empty_string_to_nil/1
                    end

                    element "TableDate" do
                      text :field_date, transform: &parse_naive_date_time/1
                    end

                    element "METADATA-TABLE" do
                      attribute "Version", :field_version, transform: &empty_string_to_nil/1
                      attribute "Date", :field_date, transform: &parse_naive_date_time/1

                      element "Table", :fields, %Field{}, list: true do
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
                          text :data_type, transform: &Field.parse_data_type/1
                        end

                        element "Precision" do
                          text :precision, transform: &parse_integer/1
                        end

                        element "Searchable" do
                          text :searchable, transform: &parse_boolean/1
                        end

                        element "Interpretation" do
                          text :interpretation, transform: &Field.parse_interpretation/1
                        end

                        element "Alignment" do
                          text :alignment, transform: &Field.parse_alignment/1
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
                          text :units, transform: &Field.parse_units/1
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
                          text :case, transform: &Field.parse_case/1
                        end
                      end
                    end

                    element "UpdateVersion" do
                      text :update_version, transform: &empty_string_to_nil/1
                    end

                    element "UpdateDate" do
                      text :update_date, transform: &parse_naive_date_time/1
                    end

                    element "METADATA-UPDATE" do
                      attribute "Version", :update_version, transform: &empty_string_to_nil/1
                      attribute "Date", :update_date, transform: &parse_naive_date_time/1

                      element "Update", :updates, %Update{}, list: true do
                        element "MetadataEntryID" do
                          text :metadata_entry_id, transform: &empty_string_to_nil/1
                        end

                        element "UpdateAction" do
                          text :update_version, transform: &Update.parse_update_action/1
                        end

                        element "Description" do
                          text :description, transform: &empty_string_to_nil/1
                        end

                        element "KeyField" do
                          text :key_field, transform: &empty_string_to_nil/1
                        end

                        element "UpdateTypeVersion" do
                          text :update_type_version, transform: &empty_string_to_nil/1
                        end

                        element "UpdateTypeDate" do
                          text :update_type_version, transform: &parse_naive_date_time/1
                        end

                        element "METADATA-UPDATE_TYPE" do
                          attribute "Version", :update_type_version,
                            transform: &empty_string_to_nil/1

                          attribute "Date", :update_type_date, transform: &parse_naive_date_time/1

                          element "UpdateType", :update_types, %UpdateType{}, list: true do
                            element "MetadataEntryID" do
                              text :metadata_entry_id, transform: &empty_string_to_nil/1
                            end

                            element "SystemName" do
                              text :system_name, transform: &empty_string_to_nil/1
                            end

                            element "Sequence" do
                              text :sequence, transform: &parse_integer/1
                            end

                            element "Attributes" do
                              text :attributes, transform: &UpdateType.parse_attributes/1
                            end

                            element "Default" do
                              text :default, transform: &empty_string_to_nil/1
                            end

                            element "ValidationExpressionID" do
                              text :validation_expression_id,
                                transform: &UpdateType.parse_validation_expression_id/1
                            end

                            element "UpdateHelpID" do
                              text :update_help_id, transform: &empty_string_to_nil/1
                            end

                            element "MaxUpdate" do
                              text :max_update, transform: &parse_integer/1
                            end

                            element "SearchResultOrder" do
                              text :search_result_order, transform: &parse_integer/1
                            end

                            element "SearchQueryOrder" do
                              text :search_query_order, transform: &parse_integer/1
                            end
                          end
                        end

                        element "RequiresBegin" do
                          text :requires_begin, transform: &parse_boolean/1
                        end
                      end
                    end

                    element "ClassTimestamp" do
                      text :class_timestamp, transform: &empty_string_to_nil/1
                    end

                    element "DeletedFlagField" do
                      text :deleted_flag_field, transform: &empty_string_to_nil/1
                    end

                    element "DeletedFlagValue" do
                      text :deleted_flag_value, transform: &empty_string_to_nil/1
                    end

                    element "HasKeyIndex" do
                      text :has_key_index, transform: &parse_boolean/1
                    end

                    element "OffsetSupport" do
                      text :offset_support, transform: &parse_boolean/1
                    end

                    element "ColumnGroupSetVersion" do
                      text :column_group_set_version, transform: &empty_string_to_nil/1
                    end

                    element "ColumnGroupSetDate" do
                      text :column_group_set_date, transform: &parse_naive_date_time/1
                    end

                    element "METADATA-COLUMN_GROUP_SET" do
                      attribute "Version", :column_group_set_version,
                        transform: &empty_string_to_nil/1

                      attribute "Date", :column_group_set_date,
                        transform: &parse_naive_date_time/1

                      element "ColumnGroupSet", :column_group_sets, %ColumnGroupSet{}, list: true do
                        element "MetadataEntryID" do
                          text :metadata_entry_id, transform: &empty_string_to_nil/1
                        end

                        element "ColumnGroupSetName" do
                          text :column_group_set_name, transform: &empty_string_to_nil/1
                        end

                        element "ColumnGroupSetParent" do
                          text :column_group_set_parent, transform: &empty_string_to_nil/1
                        end

                        element "Sequence" do
                          text :sequence, transform: &parse_integer/1
                        end

                        element "LongName" do
                          text :long_name, transform: &empty_string_to_nil/1
                        end

                        element "ShortName" do
                          text :short_name, transform: &empty_string_to_nil/1
                        end

                        element "Description" do
                          text :description, transform: &empty_string_to_nil/1
                        end

                        element "ColumnGroupName" do
                          text :column_group_name, transform: &empty_string_to_nil/1
                        end

                        element "PresentationStyle" do
                          text :presentation_style,
                            transform: &ColumnGroupSet.parse_presentation_style/1
                        end

                        element "URL" do
                          text :url, transform: &empty_string_to_nil/1
                        end

                        element "ForeignKeyID" do
                          text :foreign_key_id, transform: &empty_string_to_nil/1
                        end
                      end
                    end

                    element "ColumnGroupVersion" do
                      text :column_group_version, transform: &empty_string_to_nil/1
                    end

                    element "ColumnGroupDate" do
                      text :column_group_date, transform: &parse_naive_date_time/1
                    end

                    element "METADATA-COLUMN_GROUP" do
                      attribute "Version", :column_group_version,
                        transform: &empty_string_to_nil/1

                      attribute "Date", :column_group_date, transform: &parse_naive_date_time/1

                      element "ColumnGroup", :column_groups, %ColumnGroup{}, list: true do
                        element "MetadataEntryID" do
                          text :metadata_entry_id, transform: &empty_string_to_nil/1
                        end

                        element "ColumnGroupName" do
                          text :column_group_name, transform: &empty_string_to_nil/1
                        end

                        element "ControlSystemName" do
                          text :control_system_name, transform: &empty_string_to_nil/1
                        end

                        element "LongName" do
                          text :long_name, transform: &empty_string_to_nil/1
                        end

                        element "ShortName" do
                          text :short_name, transform: &empty_string_to_nil/1
                        end

                        element "Description" do
                          text :description, transform: &empty_string_to_nil/1
                        end

                        element "METADATA-COLUMN_GROUP_CONTROL" do
                          attribute "Version", :column_group_control_version,
                            transform: &empty_string_to_nil/1

                          attribute "Date", :column_group_control_date,
                            transform: &parse_naive_date_time/1

                          element "ColumnGroupControl",
                                  :column_group_controls,
                                  %ColumnGroupControl{},
                                  list: true do
                            element "MetadataEntryID" do
                              text :metadata_entry_id, transform: &empty_string_to_nil/1
                            end

                            element "LowValue" do
                              text :low_value, transform: &empty_string_to_nil/1
                            end

                            element "HighValue" do
                              text :high_value, transform: &empty_string_to_nil/1
                            end
                          end
                        end

                        element "METADATA-COLUMN_GROUP_TABLE" do
                          attribute "Version", :column_group_table_version,
                            transform: &empty_string_to_nil/1

                          attribute "Date", :column_group_table_date,
                            transform: &parse_naive_date_time/1

                          element "ColumnGroupTable", :column_group_tables, %ColumnGroupTable{},
                            list: true do
                            element "MetadataEntryID" do
                              text :metadata_entry_id, transform: &empty_string_to_nil/1
                            end

                            element "SystemName" do
                              text :system_name, transform: &empty_string_to_nil/1
                            end

                            element "ColumnGroupSetName" do
                              text :column_group_set_name, transform: &empty_string_to_nil/1
                            end

                            element "LongName" do
                              text :long_name, transform: &empty_string_to_nil/1
                            end

                            element "ShortName" do
                              text :short_name, transform: &empty_string_to_nil/1
                            end

                            element "DisplayOrder" do
                              text :display_order, transform: &parse_integer/1
                            end

                            element "DisplayLength" do
                              text :display_length, transform: &parse_integer/1
                            end

                            element "DisplayHeight" do
                              text :display_height, transform: &parse_integer/1
                            end

                            element "ImmediateRefresh" do
                              text :immediate_refresh, transform: &parse_boolean/1
                            end
                          end
                        end

                        element "METADATA-COLUMN_GROUP_NORMALIZATION" do
                          attribute "Version", :column_group_normalization_version,
                            transform: &empty_string_to_nil/1

                          attribute "Date", :column_group_normalization_date,
                            transform: &parse_naive_date_time/1

                          element "ColumnGroupNormalization",
                                  :column_group_normalizations,
                                  %ColumnGroupNormalization{},
                                  list: true do
                            element "MetadataEntryID" do
                              text :metadata_entry_id, transform: &empty_string_to_nil/1
                            end

                            element "TypeIdentifier" do
                              text :type_identifier, transform: &empty_string_to_nil/1
                            end

                            element "Sequence" do
                              text :sequence, transform: &empty_string_to_nil/1
                            end

                            element "ColumnLabel" do
                              text :column_label, transform: &empty_string_to_nil/1
                            end

                            element "SystemName" do
                              text :system_name, transform: &empty_string_to_nil/1
                            end
                          end
                        end
                      end
                    end
                  end
                end

                element "ObjectVersion" do
                  text :object_version, transform: &empty_string_to_nil/1
                end

                element "ObjectDate" do
                  text :object_date, transform: &parse_naive_date_time/1
                end

                element "METADATA-OBJECT" do
                  attribute "Version", :object_version, transform: &empty_string_to_nil/1
                  attribute "Date", :object_date, transform: &parse_naive_date_time/1

                  element "Object", :objects, %Object{}, list: true do
                    element "MetadataEntryID" do
                      text :metadata_entry_id, transform: &empty_string_to_nil/1
                    end

                    element "ObjectType" do
                      text :object_type, transform: &empty_string_to_nil/1
                    end

                    element "MIMEType" do
                      text :mime_type, transform: &empty_string_to_nil/1
                    end

                    element "VisibleName" do
                      text :visible_name, transform: &empty_string_to_nil/1
                    end

                    element "Description" do
                      text :description, transform: &empty_string_to_nil/1
                    end

                    element "ObjectTimeStamp" do
                      text :object_time_stamp, transform: &empty_string_to_nil/1
                    end

                    element "ObjectCount" do
                      text :object_count, transform: &empty_string_to_nil/1
                    end

                    element "LocationAvailability" do
                      text :location_availability, transform: &parse_boolean/1
                    end

                    element "PostSupport" do
                      text :post_support, transform: &parse_boolean/1
                    end

                    element "ObjectData" do
                      text :object_data, transform: &Object.parse_object_data/1
                    end

                    element "MaxFileSize" do
                      text :max_file_size, transform: &parse_integer/1
                    end
                  end
                end

                element "SearchHelpVersion" do
                  text :search_help_version, transform: &empty_string_to_nil/1
                end

                element "SearchHelpDate" do
                  text :search_help_date, transform: &parse_naive_date_time/1
                end

                element "METADATA-SEARCH_HELP" do
                  attribute "Version", :search_help_version, transform: &empty_string_to_nil/1
                  attribute "Date", :search_help_date, transform: &parse_naive_date_time/1

                  element "SearchHelp", :search_helps, %SearchHelp{}, list: true do
                    element "MetadataEntryID" do
                      text :metadata_entry_id, transform: &empty_string_to_nil/1
                    end

                    element "SearchHelpID" do
                      text :search_help_id, transform: &empty_string_to_nil/1
                    end

                    element "Value" do
                      text :value, transform: &empty_string_to_nil/1
                    end
                  end
                end

                element "EditMaskVersion" do
                  text :edit_mask_version, transform: &empty_string_to_nil/1
                end

                element "EditMaskDate" do
                  text :edit_mask_date, transform: &parse_naive_date_time/1
                end

                element "METADATA-EDITMASK" do
                  attribute "Version", :edit_mask_version, transform: &empty_string_to_nil/1
                  attribute "Date", :edit_mask_date, transform: &parse_naive_date_time/1

                  element "EditMask", :edit_masks, %EditMask{}, list: true do
                    element "MetadataEntryID" do
                      text :metadata_entry_id, transform: &empty_string_to_nil/1
                    end

                    element "EditMaskID" do
                      text :edit_mask_id, transform: &empty_string_to_nil/1
                    end

                    element "Value" do
                      text :value, transform: &empty_string_to_nil/1
                    end
                  end
                end

                element "LookupVersion" do
                  text :lookup_version, transform: &empty_string_to_nil/1
                end

                element "LookupDate" do
                  text :lookup_date, transform: &parse_naive_date_time/1
                end

                element "METADATA-LOOKUP" do
                  attribute "Version", :lookup_version, transform: &empty_string_to_nil/1
                  attribute "Date", :lookup_date, transform: &parse_naive_date_time/1

                  element "Lookup", :lookups, %Lookup{}, list: true do
                    element "MetadataEntryID" do
                      text :metadata_entry_id, transform: &empty_string_to_nil/1
                    end

                    element "LookupName" do
                      text :lookup_name, transform: &empty_string_to_nil/1
                    end

                    element "VisibleName" do
                      text :visible_name, transform: &empty_string_to_nil/1
                    end

                    element "LookupTypeVersion" do
                      text :lookup_type_version, transform: &empty_string_to_nil/1
                    end

                    element "LookupTypeDate" do
                      text :lookup_type_date, transform: &parse_naive_date_time/1
                    end

                    element "METADATA-LOOKUP_TYPE" do
                      attribute "Version", :lookup_type_version, transform: &empty_string_to_nil/1
                      attribute "Date", :lookup_type_date, transform: &parse_naive_date_time/1

                      element "LookupType", :lookup_types, %LookupType{}, list: true do
                        element "MetadataEntryID" do
                          text :metadata_entry_id, transform: &empty_string_to_nil/1
                        end

                        element "LongValue" do
                          text :long_value, transform: &empty_string_to_nil/1
                        end

                        element "ShortValue" do
                          text :short_value, transform: &empty_string_to_nil/1
                        end

                        element "Value" do
                          text :value, transform: &empty_string_to_nil/1
                        end
                      end
                    end

                    element "FilterID" do
                      text :filter_id, transform: &empty_string_to_nil/1
                    end

                    element "NotShownByDefault" do
                      text :not_shown_by_default, transform: &parse_boolean/1
                    end
                  end
                end

                element "UpdateHelpVersion" do
                  text :update_help_version, transform: &empty_string_to_nil/1
                end

                element "UpdateHelpDate" do
                  text :update_help_date, transform: &parse_naive_date_time/1
                end

                element "METADATA-UPDATE_HELP" do
                  attribute "Version", :update_help_version, transform: &empty_string_to_nil/1
                  attribute "Date", :update_help_date, transform: &parse_naive_date_time/1

                  element "UpdateHelp", :update_helps, %UpdateHelp{}, list: true do
                    element "MetadataEntryID" do
                      text :metadata_entry_id, transform: &empty_string_to_nil/1
                    end

                    element "UpdateHelpID" do
                      text :update_help_id, transform: &empty_string_to_nil/1
                    end

                    element "Value" do
                      text :value, transform: &empty_string_to_nil/1
                    end
                  end
                end

                element "ValidationExpressionVersion" do
                  text :validation_expression_version, transform: &empty_string_to_nil/1
                end

                element "ValidationExpressionDate" do
                  text :validation_expression_date, transform: &parse_naive_date_time/1
                end

                element "METADATA-VALIDATION_EXPRESSION" do
                  attribute "Version", :validation_expression_version,
                    transform: &empty_string_to_nil/1

                  attribute "Date", :validation_expression_date,
                    transform: &parse_naive_date_time/1

                  element "ValidationExpression",
                          :validation_expressions,
                          %ValidationExpression{},
                          list: true do
                    element "MetadataEntryID" do
                      text :metadata_entry_id, transform: &empty_string_to_nil/1
                    end

                    element "ValidationExpressionID" do
                      text :validation_expression_id, transform: &empty_string_to_nil/1
                    end

                    element "ValidationExpressionType" do
                      text :validation_expression_type, transform: &empty_string_to_nil/1
                    end

                    element "Value" do
                      text :value, transform: &empty_string_to_nil/1
                    end

                    element "Message" do
                      text :message, transform: &empty_string_to_nil/1
                    end

                    element "IsCaseSensitive" do
                      text :is_case_sensitive, transform: &parse_boolean/1
                    end
                  end
                end

                element "ValidationExternalVersion" do
                  text :validation_external_version, transform: &empty_string_to_nil/1
                end

                element "ValidationExternalDate" do
                  text :validation_external_date, transform: &parse_naive_date_time/1
                end

                element "METADATA-VALIDATION_EXTERNAL" do
                  attribute "Version", :validation_external_version,
                    transform: &empty_string_to_nil/1

                  attribute "Date", :validation_external_date, transform: &parse_naive_date_time/1

                  element "ValidationExternal", :validation_externals, %ValidationExternal{},
                    list: true do
                    element "MetadataEntryID" do
                      text :metadata_entry_id, transform: &empty_string_to_nil/1
                    end

                    element "ValidationExternalName" do
                      text :validation_external_name, transform: &empty_string_to_nil/1
                    end

                    element "SearchResource" do
                      text :search_resource, transform: &empty_string_to_nil/1
                    end

                    element "SearchClass" do
                      text :search_class, transform: &empty_string_to_nil/1
                    end

                    element "Version" do
                      text :version, transform: &empty_string_to_nil/1
                    end

                    element "Date" do
                      text :date, transform: &parse_naive_date_time/1
                    end

                    element "METADATA-VALIDATION_EXTERNAL_TYPE" do
                      attribute "Version", :validation_external_type_version,
                        transform: &empty_string_to_nil/1

                      attribute "Date", :validation_external_type_date,
                        transform: &parse_naive_date_time/1

                      element "ValidationExternalType",
                              :validation_external_types,
                              %ValidationExternalType{},
                              list: true do
                        element "MetadataEntryID" do
                          text :metadata_entry_id, transform: &empty_string_to_nil/1
                        end

                        element "SearchField" do
                          text :search_field, transform: &empty_string_to_nil/1
                        end

                        element "DisplayField" do
                          text :display_field, transform: &empty_string_to_nil/1
                        end

                        element "ResultFields" do
                          text :result_fields, transform: &empty_string_to_nil/1
                        end
                      end
                    end
                  end
                end
              end
            end

            element "ForeignKeyVersion" do
              text :foreign_key_version, transform: &empty_string_to_nil/1
            end

            element "ForeignKeyDate" do
              text :foreign_key_date, transform: &parse_naive_date_time/1
            end

            element "METADATA-FOREIGN_KEY" do
              attribute "Version", :foreign_key_version, transform: &empty_string_to_nil/1
              attribute "Date", :foreign_key_date, transform: &parse_naive_date_time/1

              element "ForeignKey", :foreign_keys, %ForeignKey{}, list: true do
                element "ForeignKeyID" do
                  text :foreign_key_id, transform: &empty_string_to_nil/1
                end

                element "ParentResourceID" do
                  text :parent_resource_id, transform: &empty_string_to_nil/1
                end

                element "ParentClassID" do
                  text :parent_class_id, transform: &empty_string_to_nil/1
                end

                element "ParentSystemName" do
                  text :parent_system_name, transform: &empty_string_to_nil/1
                end

                element "ChildResourceID" do
                  text :child_resource_id, transform: &empty_string_to_nil/1
                end

                element "ChildClassID" do
                  text :child_class_id, transform: &empty_string_to_nil/1
                end

                element "ChildSystemName" do
                  text :child_system_name, transform: &empty_string_to_nil/1
                end

                element "ConditionalParentField" do
                  text :conditional_parent_field, transform: &empty_string_to_nil/1
                end

                element "ConditionalParentValue" do
                  text :conditional_parent_value, transform: &empty_string_to_nil/1
                end

                element "OneToManyFlag" do
                  text :one_to_many_flag, transform: &parse_boolean/1
                end
              end
            end

            element "FilterVersion" do
              text :filter_version, transform: &empty_string_to_nil/1
            end

            element "FilterDate" do
              text :filter_date, transform: &parse_naive_date_time/1
            end

            element "METADATA-FILTER" do
              attribute "Version", :filter_version, transform: &empty_string_to_nil/1
              attribute "Date", :filter_date, transform: &parse_naive_date_time/1

              element "Filter", :filters, %Filter{}, list: true do
                element "FilterID" do
                  text :filter_id, transform: &empty_string_to_nil/1
                end

                element "ParentResource" do
                  text :parent_resource, transform: &empty_string_to_nil/1
                end

                element "ParentLookupName" do
                  text :parent_lookup_name, transform: &empty_string_to_nil/1
                end

                element "ChildResource" do
                  text :child_resource, transform: &empty_string_to_nil/1
                end

                element "ChildLookupName" do
                  text :child_lookup_name, transform: &empty_string_to_nil/1
                end

                element "NotShownByDefault" do
                  text :now_shown_by_default, transform: &parse_boolean/1
                end

                element "METADATA-FILTER_TYPE" do
                  attribute "Version", :filter_type_version, transform: &empty_string_to_nil/1
                  attribute "Date", :filter_type_date, transform: &parse_naive_date_time/1

                  element "FilterType", :filter_types, %FilterType{}, list: true do
                    element "FilterTypeID" do
                      text :filter_type_id, transform: &empty_string_to_nil/1
                    end

                    element "parent_value" do
                      text :parent_value, transform: &empty_string_to_nil/1
                    end

                    element "ChildValue" do
                      text :child_value, transform: &empty_string_to_nil/1
                    end
                  end
                end
              end
            end
          end
        end
      end
    )
  end
end
