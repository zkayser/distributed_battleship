defmodule Ocean do
  require Logger

  # Every player needs an area to work in or ships will be too close together.
  @player_ocean_ratio 10

  # There must be enough ships to blow up but not enough that it takes too long to place them or find them.
  @player_ocean_ship_ratio 20

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
    ocean_size = Enum.count(Map.keys(registered_players)) * @player_ocean_ratio

    GenServer.call(pid, {:set_size, ocean_size})
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

  def handle_call({:set_size, ocean_size}, _from_pid, state) do
    {:reply, {:ok, ocean_size}, Map.merge(state, %{ocean_size: ocean_size})} 
  end

  def handle_call({:get_size}, _from_pid, state) do
    {:reply, {:ok, state.ocean_size}, state} 
  end

  def handle_call({:ships}, _from_pid, state) do
    {:reply, {:ok, state.ships}, state} 
  end

  def handle_call({:add_ship, player, from_lat, from_long, to_lat, to_long}, _from_pid, state = %{ocean_size: ocean_size}) do
    {reply, state} = case valid_ship(ocean_size, from_lat, from_long, to_lat, to_long) do
      true  ->
        {{:ok, "Added"}, Map.merge(state, %{ships: state.ships ++ [{player, from_lat, from_long, to_lat, to_long}]})}
      false -> 
        {{:error, "off the ocean"}, state }
    end

    {:reply, reply, state}
  end
  def handle_call({:add_ship, _, _, _, _, _}, _from_pid, state) do
    {:reply, {:error, "how big the ocean blue"}, state}
  end

  def handle_call({:stop}, _from_pid, state) do
    {:stop, :normal, {:ok, "Stopped"}, state}
  end

  def handle_call(command, _from_pid, state) do
    Logger.info("Invalid command #{inspect command} : #{inspect state}")
    {:noreply, state}
  end

  defp valid_ship(ocean_size, from_lat, from_long, to_lat, to_long) do
    case {from_lat >= 0         , from_long >= 0         , to_lat >= 0         , to_long >= 0,
          from_lat < ocean_size , from_long < ocean_size , to_lat < ocean_size , to_long < ocean_size } do
      {true, true, true, true, true, true, true, true} -> true
      _                                                -> false
    end
  end

end

