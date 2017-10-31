defmodule ExOrientRest.Document do

  alias ExOrientRest.Types

  @reserved_fields ["@class", "@rid", "@version", "@type", "@fieldTypes"]

  @spec default :: Types.doc_frame
  def default, do: default("")

  @spec default(String.t) :: Types.doc_frame
  def default(class) do
    %{
      "@class" => class,
      "@rid" => "#-1:-1",
      "@version" => 0
    }
  end

  @spec new(String.t, Map) :: Types.doc_frame
  def new(class, content) do
    default(class)
    |> Map.merge(content)
  end

  @spec frame_to_content(Types.doc_frame) :: String.t
  def frame_to_content(frame) do
    frame
    |> Poison.encode!
  end

  @spec content_to_frame(String.t) :: Types.doc_frame
  def content_to_frame(content) do
    content
    |> Poison.decode!
  end

end
