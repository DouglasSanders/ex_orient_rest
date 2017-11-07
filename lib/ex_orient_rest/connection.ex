defmodule ExOrientRest.Connection do
  alias ExOrientRest.{URL, Types, Document}
  require Logger

  @default_headers %{
    "Accept"          => "Application/json; Charset=utf-8",
    "Accept-Encoding" => "gzip,deflate"
  }

  @error_status_code 500

  @spec connect(Types.db_properties, Map) :: {:ok, Types.db_connection} | {:error, Types.err}
  def connect(%{} = props, %{database: db} = opts) do
    {success, response} = URL.build_url(:get, :connect, props, opts)
    |> URI.to_string
    |> HTTPoison.get(build_headers(%{props: props}))

    case success do
      :ok ->
        if response.status_code >= 200 and response.status_code <300 do
          conn = Map.merge(%{
            props: props,
            database: db},
            cookie: ""
          )
          {:ok, conn}
        else
          {:error, %{status_code: response.status_code, reason: Poison.decode!(response.body)}}
        end
      :error ->
        {:error, %{status_code: @error_status_code, reason: response.reason}}

    end
  end

  @spec get(Types.db_connection, Types.db_get_requests, Map) :: {:ok, Map} | {:error, Types.err}
  def get(conn, type, params \\ %{}) do
    conn
    |> send_request(:get, URL.build_url(:get, type, conn, params))
    |> handle_get_response
  end

  @spec head(Types.db_connection, Types.db_head_requests, Map) :: {:ok, boolean()} | {:error, Types.err}
  def head(conn, type, params \\ %{}) do
    conn
    |> send_request(:head, URL.build_url(:head, type, conn, params))
    |> handle_response
  end

  @spec post(Types.db_connection, Types.db_post_requests, Map) :: {:ok, Map} | {:error, Types.err}
  def post(conn, type, content, params \\ %{}) do
    conn
    |> send_request(:post, URL.build_url(:post, type, conn, params), content)
    |> handle_create_response
  end

  @spec batch(Types.db_connection, Types.db_post_requests, Map) :: {:ok, Map} | {:error, Types.err}
  def batch(conn, type, content, params \\ %{}) do
    conn
    |> send_request(:post, URL.build_url(:post, type, conn, params), content)
    |> handle_batch_response
  end

  @spec put(Types.db_connection, Types.db_put_requests, String.t, Map) :: {:ok, Map} | {:error, Types.err}
  def put(conn, type, content, params \\ %{}) do
    conn
    |> send_request(:put, URL.build_url(:put, type, conn, params), content)
    |> handle_response
  end

  @spec patch(Types.db_connection, Types.db_patch_requests, Map) :: {:ok, Map} | {:error, Types.err}
  def patch(conn, type, content, params \\ %{}) do
    conn
    |> send_request(:patch, URL.build_url(:patch, type, conn, params), content)
    |> handle_response
  end

  @spec delete(Types.db_connection, Types.db_delete_requests, Map) :: {:ok} | {:error, Types.err}
  def delete(conn, type, params \\ %{}) do
    conn
    |> send_request(:delete, URL.build_url(:delete, type, conn, params))
    |> handle_delete_response
  end

  # PRIVATE

  @spec handle_response({:ok, HTTPoison.Response} | {:error, HTTPoison.Error}) :: {:ok, Map} |
                                                                                  {:error, Types.err}
  defp handle_response({success, response}) do
    case success do
      :ok ->
        if response.status_code >= 200 and response.status_code <300 do
          {:ok, Poison.decode!(response.body)}
        else
          standard_error_from_response(response)
        end
      :error ->
        server_error_from_response(response)
    end
  end

  @spec handle_get_response({:ok, HTTPoison.Response} | {:error, HTTPoison.Error}) :: {:ok, Map} |
                                                                                  {:error, Types.err}
  defp handle_get_response({success, response}) do
    case success do
      :ok ->
        case response.status_code do
          200 ->
            {:ok, Poison.decode!(response.body)}
          404 ->
            {:error, %{status_code: response.status_code, reason: %{errors: [response.body]}}}
          _ ->
            standard_error_from_response(response)
        end
      :error ->
        server_error_from_response(response)
    end
  end

  @spec handle_batch_response({:ok, HTTPoison.Response} | {:error, HTTPoison.Error}) :: {:ok, Map} |
                                                                                  {:error, Types.err}
  defp handle_batch_response({success, response}) do
    case success do
      :ok ->
        if response.status_code >= 200 and response.status_code <300 do
          {:ok}
        else
          standard_error_from_response(response)
        end
      :error ->
        server_error_from_response(response)
    end
  end

  @spec handle_create_response({:ok, HTTPoison.Response} | {:error, HTTPoison.Error}) :: {:ok, Map} |
                                                                                  {:error, Types.err}
  defp handle_create_response({success, response}) do
    case success do
      :ok ->
        case response.status_code do
          200 ->
            {:ok, Poison.decode!(response.body)}
          201 ->
            {:ok, Poison.decode!(response.body)}
          _ ->
            standard_error_from_response(response)
        end
      :error ->
        server_error_from_response(response)
    end
  end

  @spec handle_delete_response({:ok, HTTPoison.Response} | {:error, HTTPoison.Error}) :: {:ok} |
                                                                                         {:error, Types.err}
  defp handle_delete_response({success, response}) do
    case success do
      :ok ->
        case response.status_code do
          204 ->
            {:ok}
          _ ->
            standard_error_from_response(response)
        end
      :error ->
        server_error_from_response(response)
    end
  end

  @spec send_request(Types.db_connection, Types.http_method, URI.t) :: {:ok, HTTPoison.Response.t} |
                                                                          {:error, HTTPoison.Error.t}
  defp send_request(conn, method, url), do: send_request(conn, method, url, "")

  @spec send_request(Types.db_connection, Types.http_method, URI.t, String.t) :: {:ok, HTTPoison.Response.t} |
                                                                                    {:error, HTTPoison.Error.t}
  defp send_request(conn, method, url, body) do
    HTTPoison.request(method, URI.to_string(url), body, build_headers(conn, body), hackney: hackney_cookie(conn))
  end

  @spec build_headers(%{props: Types.db_properties}) :: map()
  defp build_headers(conn), do: @default_headers |> Map.merge(auth_header(conn.props))

  @spec build_headers(Types.db_connection, String.t) :: map()
  defp build_headers(conn, content) do
    build_headers(conn)
    |> Map.merge(content_length_header(content))
  end

  @spec auth_header(Types.db_connection) :: map()
  defp auth_header(%{props: %{username: username, password: password}}) do
    %{"Authorization" => "Basic " <> Base.encode64("#{username}:#{password}")}
  end

  @spec hackney_cookie(Types.db_connection) :: [cookie: [String.t]] | []
  defp hackney_cookie(%{cookie: cookie}) when cookie != "", do: [cookie: [cookie]]
  defp hackney_cookie(_), do: []

  defp content_length_header(content) do
    %{"Content-Length" => String.length(content)}
  end

  defp standard_error_from_response(response) do
    {:error, %{status_code: response.status_code, reason: Poison.decode!(response.body)}}
  end

  defp server_error_from_response(response) do
    {:error, %{status_code: @error_status_code, reason: response.reason}}
  end
end
