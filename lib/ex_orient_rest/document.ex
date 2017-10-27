defmodule ExOrientRest.Document do

  alias ExOrientRest.Types

  @spec default :: Types.doc_frame
  def default, do: default("")

  @spec default(String.t) :: Types.doc_frame
  def default(class) do
    %{
      "@class" => class,
      "@rid" => "#-1:-1",
      "@version" => 0,
      "content" => %{}
    }
  end

  @spec new(String.t, Map) :: Types.doc_frame
  def new(class, content) do
    default(class)
    |> Map.put("content", content)
  end

  @spec frame_to_content(Types.doc_frame) :: String.t
  def frame_to_content(frame) do
    frame
    |> Map.get("content", %{})
    |> Map.merge(Map.take(frame, ["@class", "@rid", "@version", "@type"]))
    |> Poison.encode!
  end

  @spec content_to_frame(String.t) :: Types.doc_frame
  def content_to_frame(content) do
    {frame, body} = content
    |> Poison.decode!
    |> Map.split(["@class", "@rid", "@version", "@type"])

    Map.merge(default(), frame)
    |> Map.put("content", body)
  end

end
