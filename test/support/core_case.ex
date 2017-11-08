defmodule ExOrientRest.CoreCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      require Logger
      import ExOrientRest.CoreCase
    end
  end

  setup_all do

    connection_props = %{
      host: "localhost",
      port: 2480,
      username: "root",
      password: "root",
      ssl: false
    }

    db = "Test"

    ExOrientRest.delete_database(connection_props, db)
    {:ok, _} = ExOrientRest.create_database(connection_props, db)
    {:ok, conn} = ExOrientRest.connect(db)

    [conn: conn]
  end

end
