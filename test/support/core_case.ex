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
    {:ok, conn} = ExOrientRest.connect("Satori")
    [conn: conn]
  end

end
