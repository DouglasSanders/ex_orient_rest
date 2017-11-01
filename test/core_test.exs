defmodule ExOrientRest.CoreTest do
  use ExOrientRest.CoreCase
  alias ExOrientRest, as: DB

  describe "connect" do
    test "setup_all returned a valid connection", setup do
      assert Map.has_key?(setup.conn, :database)
      assert Map.has_key?(setup.conn, :props)
    end

    test "connect with a non-existing DB" do
      {:error, reason} = DB.connect(Random.random_string())
      assert reason.status_code == 401
    end
  end

  describe "create_document" do
    test "successfully add an object in V", setup do
      sample_key = Random.random_string()
      sample_doc = Map.put(%{}, String.to_atom(sample_key), Random.random_string())
      {success, response} = DB.create_document(setup.conn, "V",sample_doc)
      assert success == :ok
      assert response["@class"] == "V"
      assert Map.has_key?(response, "@rid")
      assert Map.has_key?(response, sample_key)
    end

    test "fails when using an invalid param", setup do
      sample_doc = Map.put(%{}, "@rid", Random.random_string())
      {success, response} = DB.create_document(setup.conn, "V",sample_doc)
      assert success == :error
      assert response.status_code == 500
      assert Map.has_key?(response, :reason)
    end
  end

  describe "get_document" do
    test "successfully read a created document", setup do
      sample_key = Random.random_string()
      sample_doc = Map.put(%{}, String.to_atom(sample_key), Random.random_string())
      {:ok, doc} = DB.create_document(setup.conn, "V",sample_doc)
      rid = doc["@rid"]

      {success, response} = DB.get_document(setup.conn, rid)
      assert success == :ok
      assert response["@class"] == "V"
      assert Map.has_key?(response, "@rid")
      assert Map.has_key?(response, sample_key)
    end

    test "returns 404 when the document does not exist", setup do
      rid =  Random.rand_rid()
      {success, response} = DB.get_document(setup.conn, rid)
      assert success == :error
      assert response.status_code == 404
      assert Map.has_key?(response, :reason)
    end
  end

  describe "delete_document" do
    test "successfully delete a created document", setup do
      sample_doc = Map.put(%{}, :test, Random.random_string())
      {:ok, doc} = DB.create_document(setup.conn, "V", sample_doc)
      rid = doc["@rid"]

      {success} = DB.delete_document(setup.conn, rid)
      assert success == :ok

      #the document was deleted
      {success, response} = DB.get_document(setup.conn, rid)
      assert success == :error
      assert response.status_code == 404
    end

    test "returns 404 when the document does not exist", setup do
      rid =  Random.rand_rid()
      {success, response} = DB.delete_document(setup.conn, rid)
      assert success == :error
      assert response.status_code == 404
    end
  end

  describe "batch commands" do
    test "batch multiple creations", setup do
      operations = [
        %{type: "c", record: %{
        "@class" => "V",
        "name" => Random.random_string()
        }},
        %{type: "c", record: %{
        "@class" => "V",
        "name" => Random.random_string()
        }},
        %{type: "c", record: %{
          "@class" => "V",
          "name" => Random.random_string()
        }}
      ]

      {success} = DB.batch(setup.conn, operations)
      assert success == :ok
    end

    test "batch with failing transaction", setup do
      operations = [
        %{type: "c", record: %{
        "@class" => "V",
        "name" => Random.random_string()
        }},
        %{type: "d", record: %{
        "@rid" => "123:456"
        }},
        %{type: "c", record: %{
          "@class" => "V",
          "name" => Random.random_string()
        }}
      ]

      {success, reason} = DB.batch(setup.conn, operations)
      assert success == :error
      assert reason.status_code == 404

    end

  end


end
