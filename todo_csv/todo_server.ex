defmodule TodoServer do
  use GenServer

  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)

  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  def update_entry(entry_id, updater_fun) do
    GenServer.cast(__MODULE__, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(entry_id) do
    GenServer.cast(__MODULE__, {:delete_entry, entry_id})
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  @impl GenServer
  def init(_) do
    :timer.send_interval(10000, :cleanup)
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    IO.puts("performing cleanup...")
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = TodoList.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    new_state = TodoList.update_entry(todo_list, entry_id, updater_fun)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, todo_list) do
    new_state = TodoList.delete_entry(todo_list, entry_id)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, todo_list) do
    {
      :reply,
      TodoList.entries(todo_list, date),
      todo_list
    }
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  defimpl Collectable, for: TodoList do
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
