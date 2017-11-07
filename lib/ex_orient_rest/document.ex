defmodule ExOrientRest.Document do

  alias ExOrientRest.Types

  @reserved_fields ["@class", "@rid", "@version", "@type", "@fieldTypes"]

  @spec default() :: map()
  def default, do: default("")

  @spec default(String.t) :: map()
  def default(class) do
    %{
      "@class" => class,
      "@rid" => "#-1:-1"
    }
  end

  @spec new(binary(), map()) :: map()
  def new(class, content) do
    default(class)
    |> Map.merge(content)
  end
end
