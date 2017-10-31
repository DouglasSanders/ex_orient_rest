defmodule ExOrientRest.URLTest do
  use ExOrientRest.GeneralCase
  alias ExOrientRest.URL

  describe "connect" do
    test "build_url/4 with :get, :connect" do
      props = %{
        host: Random.random_string(),
        port: :rand.uniform(65530),
        ssl: false
      }
      db = %{database: Random.random_string()}

      url = URL.build_url(:get, :connect, props, db)
      |> URI.to_string

      assert url == "http://#{props.host}:#{props.port}/connect/#{db.database}"
    end
  end

  describe "disconnect" do
    test "build_url/4 with :get, :disconnect", setup do
      url = URL.build_url(:get, :disconnect, setup.conn, %{}) |> URI.to_string
      assert url == "http://#{setup.conn.props.host}:#{setup.conn.props.port}/disconnect"
    end
  end

  describe "listDatabases" do
    test "build_url/4 with :get, :listDatabases", setup do
      url = URL.build_url(:get, :listDatabases, setup.conn, %{}) |> URI.to_string
      assert url == "http://#{setup.conn.props.host}:#{setup.conn.props.port}/listDatabases"
    end
  end

  describe "document" do
    test "build_url/4 with non-post methods, :document and rid", setup do
      opts = %{rid: Random.random_number_string(3) <> ":" <> Random.random_number_string(3)}

      for method <- [:get, :head, :put, :patch, :delete] do
        url = URL.build_url(method, :document, setup.conn, opts) |> URI.to_string
        assert url == "http://#{setup.conn.props.host}:#{setup.conn.props.port}/document/#{setup.conn.database}/#{opts.rid}"
      end
    end

    test "build_url/4 with post :post, :document and rid", setup do
      opts = %{rid: Random.random_number_string(3) <> ":" <> Random.random_number_string(3)}

      url = URL.build_url(:post, :document, setup.conn, opts) |> URI.to_string
      assert url == "http://#{setup.conn.props.host}:#{setup.conn.props.port}/document/#{setup.conn.database}"
    end

    test "build_url/4 with :get, :document and rid with fetchPlan", setup do
      opts = %{
        rid: Random.random_number_string(3) <> ":" <> Random.random_number_string(3),
        fetchPlan: Random.random_number_string(3)
      }
      url = URL.build_url(:get, :document, setup.conn, opts) |> URI.to_string
      assert url == "http://#{setup.conn.props.host}:#{setup.conn.props.port}/document/#{setup.conn.database}/#{opts.rid}/#{opts.fetchPlan}"
    end
  end

end
