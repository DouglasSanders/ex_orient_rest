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

end
