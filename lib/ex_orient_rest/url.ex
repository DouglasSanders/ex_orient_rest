defmodule ExOrientRest.URL do

  def build_url(:get, :connect, props, %{database: db}) do
    build_path(props, "/connect/#{db}")
  end

  def build_url(:get, :disconnect, conn, _) do
    build_path(conn.props, "/disconnect")
  end

  def build_url(:get, :listDatabases, conn, _) do
    build_path(conn.props, "/listDatabases")
  end

  def build_url(:get, :class, conn, %{class: class}) do
    build_path(conn.props, "/class/#{conn.database}/#{class}")
  end

  def build_url(:get, :cluster, conn, %{cluster: cluster}) do
    build_path(conn.props, "/cluster/#{conn.database}/#{cluster}")
  end

  def build_url(:get, :document, conn, %{rid: rid} = opts) do
    build_path(conn.props, "/document/#{conn.database}/#{rid}#{optional_param(opts, :fetchPlan)}")
  end

  def build_url(:head, :document, conn, %{rid: rid}) do
    build_path(conn.props, "/document/#{conn.database}/#{rid}")
  end

  def build_url(:put, :document, conn, %{rid: rid}) do
    build_path(conn.props, "/document/#{conn.database}/#{rid}")
  end

  def build_url(:patch, :document, conn, %{rid: rid}) do
    build_path(conn.props, "/document/#{conn.database}/#{rid}")
  end

  def build_url(:delete, :document, conn, %{rid: rid}) do
    build_path(conn.props, "/document/#{conn.database}/#{rid}")
  end

  def build_url(:post, :document, conn, _) do
    build_path(conn.props, "/document/#{conn.database}")
  end

  def build_url(:get, :documentbyclass, conn, %{class: class, record_pos: rec_pos} = opts) do
    build_path(conn.props, "/documentbyclass/#{conn.database}/#{class}/#{rec_pos}#{optional_param(opts, :fetchPlan)}")
  end

  # PRIVATE

  defp build_path(props, path), do: base_url(props) |> struct(%{path: path})

  defp base_url(props), do: struct(URI, Map.merge(props, %{scheme: scheme(props)}))

  defp scheme(props), do: if props[:ssl], do: "https", else: "http"

  defp optional_param(opts, param) do
    if Map.has_key?(opts,param), do: "/" <> Map.get(opts, param), else: ""
  end
end
