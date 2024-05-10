defmodule KeyValueStore do
  use GenServer
  # import(ServerProcess)

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def init(_) do
    :timer.send_interval(5000, :cleanup)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    IO.puts("performing cleanup...")
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  # def start do
  #   ServerProcess.start(KeyValueStore)
  # end
  #
  # def put(pid, key, value) do
  #   ServerProcess.cast(pid, {:put, key, value})
  # end
  #
  # def get(pid, key) do
  #   ServerProcess.call(pid, {:get, key})
  # end
  #
  # def init() do
  #   %{}
  # end
  #
  # def handle_cast({:put, key, value}, state) do
  #   Map.put(state, key, value)
  # end
  #
  # def handle_call({:get, key}, state) do
  #   {Map.get(state, key), state}
  # end
end
