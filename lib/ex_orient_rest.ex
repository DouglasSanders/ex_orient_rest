defmodule ExOrientRest do

  alias ExOrientRest.{URL, Connection, Types, Document}

  @default_connection_props %{
    host: "localhost",
    port: 2480,
    username: "root",
    password: "root",
    ssl: false
  }

  def connect(db, opts \\ %{}) do
    @default_connection_props
    |> Map.merge(opts)
    |> Connection.connect(%{database: db})
  end

  def disconnect(%{} = conn) do
    Connection.get(conn, :disconnect)
  end

  @spec list_databases(Types.db_connection | Types.db_properties) :: {:ok, List} | {:error, Types.err}
  def list_databases(%{props: _} = conn) do
    Connection.get(conn, :listDatabases)
  end
  def list_databases(%{} = props), do: list_databases(props)


  @spec create_document(Types.db_connection, String.t, Map) ::  {:ok, Types.doc_frame} |
                                                                {:error, Types.err}
  def create_document(conn, class, content) do
    body = class
    |> Document.new(content)
    |> Document.frame_to_content

    Connection.post(conn, :document, body)
  end

  @spec document_exists?(Types.db_connection, String.t) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def document_exists?(conn, rid) do
    Connection.head(conn, :document, %{rid: String.replace_leading(rid, "#","")})
  end

  @spec get_document(Types.db_connection, String.t) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def get_document(conn, rid) do
    Connection.get(conn, :document, %{rid: String.replace_leading(rid, "#","")})
  end

  @spec get_document(Types.db_connection, String.t, String.t) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def get_document(conn, rid, fetch_plan) do
    Connection.get(conn, :document, %{rid: String.replace_leading(rid, "#",""), fetchPlan: fetch_plan})
  end

  @spec replace_document(Types.db_connection, Types.doc_frame) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def replace_document(conn, frame) do
    rid = Map.get(frame, "@rid") |> String.replace_leading("#","")
    Connection.put(conn, :document, Document.frame_to_content(frame), %{rid: rid})
  end

  @spec update_document(Types.db_connection, Types.doc_frame) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def update_document(conn, frame) do
    rid = Map.get(frame, "@rid") |> String.replace_leading("#","")
    Connection.patch(conn, :document, Document.frame_to_content(frame), %{rid: rid})
  end

  @spec delete_document(Types.db_connection, String.t) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def delete_document(conn, rid) do
    Connection.delete(conn, :document, %{rid: String.replace_leading(rid, "#","")})
  end

  @spec get_cluster(Types.db_connection, String.t) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def get_cluster(conn, cluster) do
    Connection.get(conn, :cluster, %{cluster: cluster})
  end

end
