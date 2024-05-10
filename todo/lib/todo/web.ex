defmodule Todo.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def child_spec(_arg) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.fetch_env!(:todo, :http_port)],
      plug: __MODULE__
    )
  end

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.add_entry(%{title: title, date: date})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  # TODO: complete /update_entry 
  # put "/update_entry" do
  #   conn = Plug.Conn.fetch_query_params(conn)
  #   list_name = Map.fetch!(conn.params, "list")
  #   id = Map.fetch!(conn.params, "id")
  #   title = Map.fetch!(conn.params, "title")
  #
  #   list_name
  #   |> Todo.Cache.server_process()
  #   |> Todo.Server.update_entry(id, _updater_fun)
  # end

  # TODO: complete /delete_entry 
  # delete "/delete_entry" do
  #   conn = Plug.Conn.fetch_query_params(conn)
  #   list_name = Map.fetch!(conn.params, "list")
  #   id = Map.fetch!(conn.params, "id")
  #
  #   list_name
  #   |> Todo.Cache.server_process()
  #   |> Todo.Server.delete_entry(id)
  #
  #   conn
  #   |> Plug.Conn.put_resp_content_type("text/plain")
  #   |> Plug.Conn.send_resp(200, "OK")
  # end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    entries =
      list_name
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(date)

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.date} #{&1.title}")
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end
end
