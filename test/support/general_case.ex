defmodule ExOrientRest.GeneralCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      require Logger
      import ExOrientRest.GeneralCase
    end
  end

  setup do
    test_conn = %{
      database: Random.random_string(),
      cookie: Random.random_string(),
      props: %{
        host: Random.random_string(),
        port: :rand.uniform(65530),
        ssl: false,
        username: Random.random_string(),
        password: Random.random_string()
      }
    }
    [conn: test_conn]
  end

end
