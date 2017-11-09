defmodule Ocean do
  require Logger

  def start() do
    {:ok, pid} = GenServer.start_link(Ocean.Server, %{ships: []}, name: {:global, :ocean})

    pid
  end

  def stop(), do: stop(:global.whereis_name(:ocean))
  def stop(:undefined), do: {:ok, "Already Stopped"}
  def stop(pid) do
    case Process.alive?(pid) do
      true  -> GenServer.call(pid, {:stop})
      false -> {:ok, "Aleady Stopped"}
    end
  end

  # Ocean size is a function of the number of players 
  def size(pid, registered_players) do
    size = Enum.count(Map.keys(registered_players)) * 10

    GenServer.call(pid, {:set_size, size})
  end
  def size(pid) do
    GenServer.call(pid, {:get_size})
  end

  def ships(pid) do
    GenServer.call(pid, {:ships})
  end

  def add_ship(pid, player, from_lat, from_long, to_lat, to_long) do
    GenServer.call(pid, {:add_ship, player, from_lat, from_long, to_lat, to_long})
  end
end

defmodule Ocean.Server do
  use GenServer
  require Logger

  def handle_call({:stop}, _from_pid, state) do
    {:stop, :normal, {:ok, "Stopped"}, state}
  end

  def handle_call({:ships}, _from_pid, state) do
    {:reply, {:ok, state.ships}, state} 
  end

  def handle_call({:add_ship, player, from_lat, from_long, to_lat, to_long}, _from_pid, state = %{size: size}) do
    {reply, state} = case {
        from_lat >= 0, from_long >= 0, to_lat >= 0, to_long >= 0,
        from_lat < size, from_long < size, to_lat < size, to_long < size
      } do
      {true, true, true, true, true, true, true, true} -> 
        {{:ok, "Added"}, Map.merge(state, %{ships: state.ships ++ [{player, from_lat, from_long, to_lat, to_long}]})}
      _ -> 
        {{:error, "off the ocean"}, state }
    end

    {:reply, reply, state}
  end
  def handle_call({:add_ship, _, _, _, _, _}, _from_pid, state) do
    {:reply, {:error, "how big the ocean blue"}, state}
  end

  def handle_call({:set_size, size}, _from_pid, state) do
    {:reply, {:ok, size}, Map.merge(state, %{size: size})} 
  end

  def handle_call({:get_size}, _from_pid, state) do
    {:reply, {:ok, state.size}, state} 
  end

  def handle_call(command, _from_pid, state) do
    Logger.info("Invalid command #{inspect command} : #{inspect state}")
    {:noreply, state}
  end

end

