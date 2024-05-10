defmodule Todo.Server do
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
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    IO.puts("performing cleanup...")
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    new_state = Todo.List.update_entry(todo_list, entry_id, updater_fun)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, todo_list) do
    new_state = Todo.List.delete_entry(todo_list, entry_id)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, todo_list) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      todo_list
    }
  end
end
