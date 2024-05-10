defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    test_pid = Todo.Cache.server_process(cache, "test")

    assert test_pid != Todo.Cache.server_process(cache, "wrong")
    assert test_pid == Todo.Cache.server_process(cache, "test")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()

    test_pid = Todo.Cache.server_process(cache, "test")
    Todo.Server.add_entry(test_pid, %{date: ~D[2024-04-07], title: "Create Test"})

    entries = Todo.Server.entries(test_pid, ~D[2024-04-07])
    assert [%{id: 1, date: ~D[2024-04-07], title: "Create Test"}] == entries
  end
end
