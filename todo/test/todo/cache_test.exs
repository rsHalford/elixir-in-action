defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    test_pid = Todo.Cache.server_process("test_1")

    assert test_pid != Todo.Cache.server_process("wrong")
    assert test_pid == Todo.Cache.server_process("test_1")
  end

  test "to-do operations" do
    test_pid = Todo.Cache.server_process("test_2")
    Todo.Server.add_entry(test_pid, %{date: ~D[2024-04-14], title: "Create Test"})
    entries = Todo.Server.entries(test_pid, ~D[2024-04-14])

    assert [%{id: 1, date: ~D[2024-04-14], title: "Create Test"}] == entries
  end

  test "to-do persistence" do
    test_pid = Todo.Cache.server_process("test_3")
    Todo.Server.add_entry(test_pid, %{date: ~D[2024-04-14], title: "Create Test"})
    assert 1 == length(Todo.Server.entries(test_pid, ~D[2024-04-14]))

    Process.exit(test_pid, :kill)

    entries =
      "test_3"
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(~D[2024-04-14])

    assert [%{id: 1, date: ~D[2024-04-14], title: "Create Test"}] = entries
  end
end
