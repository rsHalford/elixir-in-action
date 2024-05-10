defmodule Todo.ListTest do
  use ExUnit.Case, async: true

  test "empty list" do
    assert Todo.List.size(Todo.List.new()) == 0
  end

  test "entries" do
    todo_list =
      Todo.List.new([
        %{date: ~D[2024-04-14], title: "Test1"},
        %{date: ~D[2024-04-13], title: "Test2"},
        %{date: ~D[2024-04-14], title: "Test3"}
      ])

    assert Todo.List.size(todo_list) == 3
    assert todo_list |> Todo.List.entries(~D[2024-04-14]) |> length() == 2
    assert todo_list |> Todo.List.entries(~D[2024-04-13]) |> length() == 1
    assert todo_list |> Todo.List.entries(~D[2024-04-15]) |> length() == 0

    titles = todo_list |> Todo.List.entries(~D[2024-04-14]) |> Enum.map(& &1.title)
    assert ["Test1", "Test3"] = titles
  end

  test "add_entry" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: ~D[2024-04-14], title: "Test1"})
      |> Todo.List.add_entry(%{date: ~D[2024-04-13], title: "Test2"})
      |> Todo.List.add_entry(%{date: ~D[2024-04-14], title: "Test3"})

    assert Todo.List.size(todo_list) == 3
    assert todo_list |> Todo.List.entries(~D[2024-04-14]) |> length() == 2
    assert todo_list |> Todo.List.entries(~D[2024-04-13]) |> length() == 1
    assert todo_list |> Todo.List.entries(~D[2024-04-15]) |> length() == 0

    titles = todo_list |> Todo.List.entries(~D[2024-04-14]) |> Enum.map(& &1.title)
    assert ["Test1", "Test3"] = titles
  end

  test "update_entry" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: ~D[2024-04-14], title: "Test1"})
      |> Todo.List.add_entry(%{date: ~D[2024-04-13], title: "Test2"})
      |> Todo.List.add_entry(%{date: ~D[2024-04-14], title: "Test3"})
      |> Todo.List.update_entry(2, &Map.put(&1, :title, "Updated Test2"))

    assert Todo.List.size(todo_list) == 3
    assert [%{title: "Updated Test2"}] = Todo.List.entries(todo_list, ~D[2024-04-13])
  end

  test "delete_entry" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: ~D[2024-04-14], title: "Test1"})
      |> Todo.List.add_entry(%{date: ~D[2024-04-13], title: "Test2"})
      |> Todo.List.add_entry(%{date: ~D[2024-04-14], title: "Test3"})
      |> Todo.List.delete_entry(2)

    assert Todo.List.size(todo_list) == 2
    assert Todo.List.entries(todo_list, ~D[2024-04-13]) == []
  end
end
