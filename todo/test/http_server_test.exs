defmodule HttpServerTest do
  use ExUnit.Case, async: false
  use Plug.Test

  test "no entries" do
    assert get("/entries?list=test_1&date=2024-07-14").status == 200
    assert get("/entries?list=test_1&date=2024-07-14").resp_body == ""
  end

  test "adding an entry" do
    resp = post("/add_entry?list=test_2&date=2024-07-14&title=Test")

    assert resp.status == 200
    assert resp.resp_body == "OK"
    assert get("/entries?list=test_2&date=2024-07-14").resp_body == "2024-07-14 Test"
  end

  defp get(path) do
    Todo.Web.call(conn(:get, path), Todo.Web.init([]))
  end

  defp post(path) do
    Todo.Web.call(conn(:post, path), Todo.Web.init([]))
  end
end
