defmodule ExOrientRest.Connection do
  alias ExOrientRest.{URL, Types, Document}
  require Logger


  @default_headers %{
    "Accept"          => "Application/json; Charset=utf-8",
    "Accept-Encoding" => "gzip,deflate"
  }


  @spec connect(Types.db_properties, Map) :: {:ok, Types.db_connection} | {:error, Types.err}
  def connect(%{} = props, %{database: db} = opts) do
    {success, response} = URL.build_url(:get, :connect, props, opts)
    |> URI.to_string
    |> HTTPoison.get(build_headers(props))

    case success do
      :ok ->
        conn = Map.merge(%{
          props: props,
          database: db},
          get_cookie(response)
        )
        {:ok, conn}
      :error -> {:error, %{status_code: response.status_code, reason: response.body}}
    end
  end

  @spec get(Types.db_connection, Types.db_get_requests, Map) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def get(conn, type, params \\ %{}) do
    conn
    |> send_request(:get, URL.build_url(:get, type, conn, params))
    |> handle_response
  end

  @spec head(Types.db_connection, Types.db_head_requests, Map) :: {:ok, boolean()} | {:error, Types.err}
  def head(conn, type, params \\ %{}) do
    conn
    |> send_request(:head, URL.build_url(:head, type, conn, params))
    |> handle_response
  end

  @spec post(Types.db_connection, Types.db_post_requests, Map) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def post(conn, type, content, params \\ %{}) do
    conn
    |> send_request(:post, URL.build_url(:post, type, conn, params), content)
    |> handle_response
  end

  @spec put(Types.db_connection, Types.db_put_requests, Map) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def put(conn, type, content, params \\ %{}) do
    conn
    |> send_request(:put, URL.build_url(:put, type, conn, params), content)
    |> handle_response
  end

  @spec patch(Types.db_connection, Types.db_patch_requests, Map) :: {:ok, Types.doc_frame} | {:error, Types.err}
  def patch(conn, type, content, params \\ %{}) do
    conn
    |> send_request(:patch, URL.build_url(:patch, type, conn, params), content)
    |> handle_response
  end

  @spec delete(Types.db_connection, Types.db_delete_requests, Map) :: {:ok} | {:error, Types.err}
  def delete(conn, type, params \\ %{}) do
    conn
    |> send_request(:delete, URL.build_url(:delete, type, conn, params))
    |> handle_response
  end

  # PRIVATE

  @spec handle_response({:ok, HTTPoison.Response} | {:error, HTTPoison.Error}) :: {:ok, Types.doc_frame} |
                                                                                  {:error, Types.err}
  defp handle_response({success, response}) do
    case success do
      :ok ->
        cond do
          (response.status_code>=200 and response.status_code<300) ->
            {:ok, Document.content_to_frame(response.body)}
          true ->
            {:error, %{status_code: response.status_code, reason: Poison.decode!(response.body)}}
        end
      :error ->
        {:error, %{status_code: -1, reason: response.reason}}
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

  @spec get_cookie(%HTTPoison.Response{}) :: Map
  defp get_cookie(%HTTPoison.Response{} = response) do
    cookie = Enum.filter(response.headers, fn(x) -> elem(x,0) == "Set-Cookie" end)
    |> Enum.map(fn(x) -> elem(x,1) end)

    unless Enum.empty?(cookie), do: %{cookie: Enum.at(cookie,0)}, else: %{}
  end

  @spec build_headers(Types.db_properties) :: Types.db_properties
  defp build_headers(props), do: @default_headers |> Map.merge(auth_header(props))

  @spec build_headers(Types.db_properties, String.t) :: Types.db_properties
  defp build_headers(props, content) do
    build_headers(props)
    |> Map.merge(content_length_header(content))
  end

  @spec auth_header(Types.db_properties) :: Map
  defp auth_header(props) do
    if props[:cookie], do: %{}, else:
      %{"Authorization" => "Basic " <> Base.encode64("#{props.username}:#{props.password}")}
  end

  @spec hackney_cookie(Types.db_connection) :: List
  defp hackney_cookie(%{cookie: cookie}), do: [cookie: [cookie]]
  defp hackney_cookie(%{}), do: []

  @spec content_length_header(String.t) :: Map
  defp content_length_header(content) do
    %{"Content-Length" => byte_size(content)}
  end
end