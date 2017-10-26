defmodule ExOrientRest do
  @moduledoc """
  Documentation for ExOrientRest.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExOrientRest.hello
      :world

  """

  alias ExOrientRest.{URL, Connection}

  @default_connection_props %{
    host: "localhost",
    port: 2480,
    username: "root",
    password: "root",
    database: "Satori",
    ssl: false
  }

  def connect(opts \\ %{}) do
    @default_connection_props
    |> Map.merge(opts)
    |> Connection.connect
  end

  def disconnect(%{} = conn) do
    Connection.disconnect(conn)
  end

  def listDatabases(%{cookie: _} = conn) do
    Connection.listDatabases(conn)
  end
end
