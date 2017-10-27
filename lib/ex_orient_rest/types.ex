defmodule ExOrientRest.Types do

  @typedoc """
  Properties for connecting to the remote server, including
  Basic authentication credentials.
  """
  @type db_properties :: %{
    host: String.t,
    port: non_neg_integer() ,
    username: String.t,
    password: String.t,
    ssl: boolean()
  }

  @typedoc """
  Properties of an active connection to the DB, which has the HTTP Keep-Alive
  set by default.  We store the most recent cookie as well.
  """
  @type db_connection :: %{
    props: db_properties,
    database: String.t,
    cookie: String.t
  }

  @typedoc """
  Valid HTTP Request types
  """
  @type http_method :: :get | :head | :post | :put | :patch | :delete

  @typedoc """
  Valid requests to make on a request of the type, with a database
  """
  @type db_get_requests :: :connect | :database | :class | :cluster |
    :function | :export | :disconnect | :document |
    :documentbyclass | :allocation | :index | :query

  @type db_head_requests :: :document | :documentbyclass

  @type db_post_requests :: :database | :class | :property | :command |
    :batch | :function | :import | :document

  @type db_put_requests :: :document | :index

  @type db_patch_requests :: :document

  @type db_delete_requests :: :document | :index | :database

  @typedoc """
  An error we want to return to the client.
  """
  @type err :: %{reason: any(), status_code: non_neg_integer()}

  @typedoc """
  Document metadata, and storage for the nested document.
  """
  @type doc_frame :: %{}

  @spec blank_doc(String.t) :: doc_frame
  def blank_doc(class) do
    %{
      "@class" => class,
      "@rid" => "#-1:-1",
      "@version" => 0,
      "content" => %{}
    }
  end

  @spec new_doc(String.t, Map) :: doc_frame
  def new_doc(class, content) do
    blank_doc(class)
    |> Map.put("content", content)
  end

  @spec frame_to_content(doc_frame) :: String.t
  def frame_to_content(frame) do
    frame
    |> Map.get("content", %{})
    |> Map.merge(Map.take(frame, ["@class", "@rid", "@version"]))
    |> Poison.encode!
  end

  @spec content_to_frame(String.t) :: doc_frame
  def content_to_frame(content) do
    {frame, body} = content
    |> Poison.decode!
    |> Map.split(["@class", "@rid", "@version"])

    Map.merge(blank_doc(""), frame)
    |> Map.put("content", body)
  end

end
