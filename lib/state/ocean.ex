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

  def handle_call({:add_ship, player, from_lat, from_long, to_lat, to_long}, _from_pid, state) do
    state = Map.merge(state, %{ships: state.ships ++ [{player, from_lat, from_long, to_lat, to_long}]})
    {:reply, {:ok, "Added"}, state} 
  end

  def handle_call(command, _from_pid, state) do
    Logger.info("Invalid command #{inspect command} : #{inspect state}")
    {:noreply, state}
  end

end

