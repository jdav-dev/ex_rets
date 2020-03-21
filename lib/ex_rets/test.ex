defmodule ExRets.Test do
  # import ExRets.Xml
  import ExRets.Xml2

  alias ExRets.HttpClient.Mock
  alias ExRets.Metadata
  alias ExRets.RetsResponse

  @standard_xml_metadata File.read!("/home/jdavis/Downloads/metadata_standard.xml")
  @standard_xml_stream [@standard_xml_metadata]

  # def test do
  #   parse_xml @standard_xml_stream do
  #     root RetsResponse do
  #       entity :response, Metadata
  #     end
  #   end
  # end

  def test2 do
    parse_xml @standard_xml_stream, Mock do
      root "RETS", %RetsResponse{} do
        attribute "ReplyCode", :reply_code
        attribute "ReplyText", :reply_text

        element "METADATA" do
          element "METADATA-SYSTEM", :response, %Metadata{} do
            attribute "Version", :version
            attribute "Date", :date, &parse_date/1

            element "SYSTEM" do
              attribute "SystemID", :system_id
              attribute "SystemDescription", :system_description
              attribute "TimeZoneOffset", :time_zone_offset
              attribute "MetadataID", :metadata_id

              element "COMMENTS" do
                text :comments
              end

              element "ResourceVersion" do
                text :resource_version
              end

              element "ResourceDate" do
                text :resource_date, &parse_date/1
              end

              element "ForeignKeyVersion" do
                text :foreign_key_version
              end

              element "ForeignKeyDate" do
                text :foreign_key_date, &parse_date/1
              end

              element "FilterVersion" do
                text :filter_version
              end

              element "FilterDate" do
                text :filter_date, &parse_date/1
              end
            end
          end
        end
      end
    end
  end

  defp parse_date(date_time) do
    case NaiveDateTime.from_iso8601(date_time) do
      {:ok, naive_date_time} -> naive_date_time
      _ -> date_time
    end
  end
end
