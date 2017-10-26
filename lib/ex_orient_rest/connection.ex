defmodule ExOrientRest.Connection do
  alias ExOrientRest.{URL}
  require Logger

  @default_headers %{
    "Accept"          => "Application/json; Charset=utf-8",
    "Accept-Encoding" => "gzip,deflate"
  }

  def connect(%{} = props) do
    {success, response} = URL.action_url(:connect, props)
    |> URI.to_string
    |> HTTPoison.get(build_headers(props))

    case success do
      :ok -> {:ok, get_conn(response, props)}
      :error -> {:error, get_err(response)}
    end
  end

  def disconnect(%{} = props) do
    {success, response} = URL.action_url(:disconnect, props)
    |> URI.to_string
    |> HTTPoison.get(build_headers(props))

    case success do
      :ok -> {:ok}
      :error -> {:error, get_err(response)}
    end
  end

  def listDatabases(%{} = props) do
    {success, response} = URL.action_url(:listDatabases, props)
    |> URI.to_string
    |> HTTPoison.get(build_headers(props))

    case success do
      :ok -> {:ok, get_conn(response, props), get_body(response)["databases"]}
      :error -> {:error, get_err(response)}
    end
  end

  defp get_conn(%HTTPoison.Response{} = response, props) do
    cookie = Enum.filter(response.headers, fn(x) -> elem(x,0) == "Set-Cookie" end)
    |> Enum.map(fn(x) -> elem(x,1) end)


    if Enum.empty?(cookie),
      do: props,
      else: Map.merge(props,%{cookie: Enum.at(cookie,0)})

  end

  defp get_err(%HTTPoison.Error{reason: reason}) do
    %{reason: reason}
  end

  defp get_body(res) do
    Poison.decode!(res.body)
  end

  defp build_headers(props) do
    @default_headers
    |> Map.merge(auth_header(props))
  end

  defp build_headers(props, content) do
    build_headers(props)
    |> Map.merge(content_length_header(content))
  end

  defp auth_header(props) do
    if props[:cookie], do: %{}, else:
      %{"Authorization" => "Basic " <> Base.encode64("#{props.username}:#{props.password}")}
  end

  defp hackney_cookie(%{cookie: cookie}), do: [cookie: [cookie]]
  defp hackney_cookie(%{}), do: []

  defp content_length_header(content) do
    %{"Content-Length" => byte_size(content)}
  end

end
