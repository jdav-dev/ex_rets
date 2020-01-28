defmodule ExRets.BaseXmlParserTest do
  use ExUnit.Case, async: true

  alias ExRets.BaseXmlParser
  alias ExRets.HttpClient.Mock
  alias ExRets.HttpRequest

  doctest BaseXmlParser

  @http_request %HttpRequest{uri: URI.parse("https://www.w3schools.com/xml/note.xml")}

  @valid_xml """
  <?xml version="1.0" encoding="UTF-8"?>
  <note>
    <to>Tove</to>
    <from>Jani</from>
    <heading>Reminder</heading>
    <body>Don't forget me this weekend!</body>
  </note>
  """

  @invalid_xml """
  <?xml version="1.0" encoding="UTF-8"?>
  <note>
    <to>Tove</to>
    <from>Jani</Ffrom>
    <heading>Reminder</heading>
    <body>Don't forget me this weekend!</body>
  </note>
  """

  @event_state %{characters: [], result: %{}}

  defp event_fun({:startElement, _, _element, _, _attributes}, _, state) do
    Map.put(state, :characters, [])
  end

  defp event_fun({:characters, characters}, _, state) do
    Map.update!(state, :characters, fn existing_characters ->
      [characters | existing_characters]
    end)
  end

  defp event_fun({:endElement, _, element, _}, _, state) do
    value =
      state
      |> Map.get(:characters, [])
      |> Enum.reverse()
      |> Enum.join("")

    state
    |> Map.put(:characters, [])
    |> Map.update!(:result, &Map.put(&1, to_string(element), value))
  end

  defp event_fun(_event, _, state), do: state

  describe "parse/4" do
    @tag :unit
    test "returns the result of `event_fun` for valid XML" do
      stream = stream_from_string(@valid_xml)

      assert {:ok, %{result: result}} =
               BaseXmlParser.parse(stream, &event_fun/3, @event_state, Mock)

      assert %{
               "note" => "",
               "to" => "Tove",
               "from" => "Jani",
               "heading" => "Reminder",
               "body" => "Don't forget me this weekend!"
             } = result
    end

    @tag :unit
    test "returns error tuple for invalid XML" do
      stream = stream_from_string(@invalid_xml)

      assert {:error, "EndTag: :Ffrom, does not match StartTag"} =
               BaseXmlParser.parse(stream, &event_fun/3, @event_state, Mock)
    end

    @tag :unit
    test "returns error tuple when stream returns an error at the beginning" do
      stream = [:connection_closed]

      assert {:error, :connection_closed} =
               BaseXmlParser.parse(stream, &event_fun/3, @event_state, Mock)
    end

    @tag :unit
    test "returns error tuple when stream returns an error mid-stream" do
      stream = ["<?xml vers", :connection_closed]

      assert {:error, :connection_closed} =
               BaseXmlParser.parse(stream, &event_fun/3, @event_state, Mock)
    end
  end

  defp stream_from_string(string) do
    {:ok, client} = Mock.start_client(:xml_parser_test, stream: chunk_string(string))
    {:ok, _, stream} = Mock.open_stream(client, @http_request)
    stream
  end

  defp chunk_string(string) do
    string
    |> String.to_charlist()
    |> Enum.chunk_every(10)
    |> Enum.map(&to_string/1)
  end
end
