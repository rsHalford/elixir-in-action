defmodule TodoServer do
  def start do
    spawn(fn ->
      Process.register(self(), :todo_list)
      loop(TodoList.new())
    end)
  end

  def add_entry(new_entry) do
    send(:todo_list, {:add_entry, new_entry})
  end

  def entries(date) do
    send(:todo_list, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def update_entry(entry_id, updater_fun) do
    send(:todo_list, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(entry_id) do
    send(:todo_list, {:delete_entry, entry_id})
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:update_entry, entry_id, updater_fun}) do
    TodoList.update_entry(todo_list, entry_id, updater_fun)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  defimpl Collectable, for: TodoList do
    # Alternavtive way of expressing this.
    # def into(original) do
    #   {original, &into_callback/2}
    # end
    #
    # def into_callback(todo_list, {:cont, entry}) do
    #   TodoList.add_entry(todo_list, entry)
    # end
    #
    # def into_callback(todo_list, :done), do: todo_list
    # def into_callback(_todo_list, :halt), do: :ok

    def into(todo_list) do
      collector_fun = fn
        todo_list_acc, {:cont, elem} ->
          TodoList.add_entry(todo_list_acc, elem)

        todo_list_acc, :done ->
          todo_list_acc

        _todo_list_acc, :halt ->
          :ok
      end

      initial_acc = todo_list

      {initial_acc, collector_fun}
    end
  end

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    %TodoList{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

defmodule TodoList.CsvImporter do
  def import(path) do
    path
    |> read_lines()
    |> create_entries()
    |> TodoList.new()
  end

  defp read_lines(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end

  defp create_entries(lines) do
    Stream.map(
      lines,
      fn line ->
        [date_string, title] = String.split(line, ",")
        date = Date.from_iso8601!(date_string)
        %{date: date, title: title}
      end
    )
  end
end

defmodule MultiDict do
  def new(), do: %{}

  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end

  def get(dict, key) do
    Map.get(dict, key, [])
  end
end
