defmodule Players do
  require Logger

  def start() do
    {:ok, pid} = GenServer.start(Players.Server, %{players: %{}, active: true}, name: {:global, :players})

    pid
  end

  def stop(), do: stop(:global.whereis_name(:players))
  def stop(:undefined), do: {:ok, "Aleady Stopped"}
  def stop(pid) do
    case Process.alive?(pid) do
      true  -> GenServer.call(pid, {:stop})
      false -> {:ok, "Already Stopped"}
    end
  end

  def player_count(pid) do
    GenServer.call(pid, {:player_count})
  end

  def register(pid, player_name) do
    GenServer.call(pid, {:register, player_name})
  end

  def registered_players(pid) do
    GenServer.call(pid, {:registered_players})
  end

  def stop_registering(pid) do
    GenServer.call(pid, {:stop_registering})
  end
end

defmodule Players.Server do
  use GenServer
  require Logger

  def handle_call({:stop}, _from_pid, state) do
    {:stop, :normal, {:ok, "Stopped"}, state}
  end

  def handle_call({:player_count}, _from_pid,  state) do
    {:reply, {:ok, length(Node.list)}, state}
  end

  def handle_call({:register, player_name}, {from_pid, _}, state = %{active: false}) do
    Logger.info("Can not registered #{inspect from_pid}: #{player_name}")
    {:reply, {:error, "can not register anymore"}, state}
  end
  def handle_call({:register, player_name}, {from_pid, _ }, state) do
    Logger.info("Registered #{inspect from_pid}: #{player_name}")
    players = Map.merge(state.players, %{player_name => from_pid})
    state = Map.merge(state, %{players: players})
    {:reply, {:ok, "Now there are #{players |> Map.keys |> length} players"}, state}
  end

  def handle_call({:registered_players}, _from_pid, state) do
    {:reply, {:ok, state.players}, state}
  end

  def handle_call({:stop_registering}, _from_pid, state) do
    {:reply, {:ok, state.players}, Map.merge(state, %{active: false})}
  end

  def handle_call(message, _from_pid, state) do
    Logger.warn("Players message not supported: #{inspect message}")
    {:noreply, state}
  end

end

