defmodule ExOrientRest.Document do

  alias ExOrientRest.Types

  @reserved_fields ["@class", "@rid", "@version", "@type", "@fieldTypes"]

  @spec default :: Map
  def default, do: default("")

  @spec default(String.t) :: Map
  def default(class) do
    %{
      "@class" => class,
      "@rid" => "#-1:-1"
    }
  end

  @spec new(String.t, Map) :: Map
  def new(class, content) do
    default(class)
    |> Map.merge(content)
  end

  @spec frame_to_content(Map) :: String.t
  def frame_to_content(frame) do
    frame
    |> Poison.encode!
  end

  @spec content_to_frame(String.t) :: Map
  def content_to_frame(content) do
    content
    |> Poison.decode!
  end

end
