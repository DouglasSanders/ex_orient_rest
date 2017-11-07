defmodule ExOrientRest do

  alias ExOrientRest.{URL, Connection, Types, Document}

  @default_connection_props %{
    host: "localhost",
    port: 2480,
    username: "root",
    password: "root",
    ssl: false
  }

  def connect(db, %{} = opts \\ %{}) when is_binary(db) do
    @default_connection_props
    |> Map.merge(opts)
    |> Connection.connect(%{database: db})
  end

  @spec list_databases(Types.db_connection | Types.db_properties) :: {:ok, List} | {:error, Types.err}
  def list_databases(%{props: _} = conn) do
    Connection.get(conn, :listDatabases)
  end
  def list_databases(%{} = props), do: list_databases(props)

  @spec create_database(Map, String.t) :: {:ok, Map} | {:error, Types.err}
  def create_database(%{} = props, name, storage \\ "plocal") do
    props = @default_connection_props |> Map.merge(props)
    %{props: props, database: name}
    |> Connection.post(:database, "", %{db_storage: storage})
  end

  @spec get_database(Map, String.t) :: {:ok, Map} | {:error, Types.err}
  def get_database(%{} = props, name) do
    props = @default_connection_props |> Map.merge(props)
    %{props: props, database: name}
    |> Connection.get(:database)
  end

  @spec delete_database(Map, String.t) :: {:ok} | {:error, Types.err}
  def delete_database(%{} = props, name) do
    props = @default_connection_props |> Map.merge(props)
    %{props: props, database: name}
    |> Connection.delete(:database)
  end

  @spec create_document(Types.db_connection, String.t, Map) ::  {:ok, Map} |
                                                                {:error, Types.err}
  def create_document(conn, class, content) do
    body = class
    |> Document.new(content)
    |> Poison.encode!

    Connection.post(conn, :document, body)
  end

  @spec document_exists?(Types.db_connection, String.t) :: {:ok, Map} | {:error, Types.err}
  def document_exists?(conn, rid) do
    Connection.head(conn, :document, %{rid: String.replace_leading(rid, "#","")})
  end

  @spec get_document(Types.db_connection, String.t) :: {:ok, Map} | {:error, Types.err}
  def get_document(conn, rid) do
    Connection.get(conn, :document, %{rid: String.replace_leading(rid, "#","")})
  end

  @spec get_document(Types.db_connection, String.t, String.t) :: {:ok, Map} | {:error, Types.err}
  def get_document(conn, rid, fetch_plan) do
    Connection.get(conn, :document, %{rid: String.replace_leading(rid, "#",""), fetchPlan: fetch_plan})
  end

  @spec replace_document(Types.db_connection, Map) :: {:ok, Map} | {:error, Types.err}
  def replace_document(conn, frame) do
    rid = Map.get(frame, "@rid") |> String.replace_leading("#","")
    Connection.put(conn, :document, Poison.encode!(frame), %{rid: rid})
  end

  @spec update_document(Types.db_connection, Map) :: {:ok, Map} | {:error, Types.err}
  def update_document(conn, frame) do
    rid = Map.get(frame, "@rid") |> String.replace_leading("#","")
    Connection.patch(conn, :document, Poison.encode!(frame), %{rid: rid})
  end

  @spec delete_document(Types.db_connection, String.t) :: {:ok, Map} | {:error, Types.err}
  def delete_document(conn, rid) do
    Connection.delete(conn, :document, %{rid: String.replace_leading(rid, "#","")})
  end

  @spec get_cluster(Types.db_connection, String.t) :: {:ok, Map} | {:error, Types.err}
  def get_cluster(conn, cluster) do
    Connection.get(conn, :cluster, %{cluster: cluster})
  end

  @spec batch(Types.db_connection, List, boolean()) :: {:ok} | {:error, Types.err}
  def batch(conn, ops, xaction \\ true) do
    Connection.batch(conn, :batch, "{\"transaction\": #{xaction}, \"operations\": #{Poison.encode!(ops)}}")
  end

  @spec command(Types.db_connection, String.t, Map) :: {:ok, String.t} | {:error, Types.err}
  def command(conn, language, content) do
    body = content |> Poison.encode!
    Connection.post(conn, :command, body, %{language: language})
  end

  @spec get_class(Types.db_connection, String.t) :: {:ok, Map} | {:error, Types.err}
  def get_class(conn, class) do
    Connection.get(conn, :class, %{class: class})
  end

  def create_class(conn, class) do
    Connection.post(conn, :class, "", %{class: class})
  end

  def add_properties(conn, class, props) do
    body = props |> Poison.encode!
    Connection.post(conn, :property, body, %{class: class})
  end
end
