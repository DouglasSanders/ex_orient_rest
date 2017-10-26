defmodule ExOrientRest.URL do

  def action_url(:connect, props) do
    base_url(props) |> Map.merge(%{path: "/connect/#{props.database}"})
  end

  def action_url(:disconnect, props) do
    base_url(props) |> Map.merge(%{path: "/disconnect"})
  end

  def action_url(:listDatabases, props) do
    base_url(props) |> Map.merge(%{path: "/listDatabases"})
  end


  def base_url(props) do
    struct(URI, Map.merge(props, %{scheme: scheme(props)}))
  end

  defp scheme(props), do: if props[:ssl], do: "https", else: "http"
end
