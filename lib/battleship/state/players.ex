defmodule Players do
  require Logger

  def start() do
    {:ok, pid} = GenServer.start(Players.Server, %{}, name: {:global, :players})

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
end

defmodule Players.Server do
  use GenServer
  require Logger

  def handle_call({:stop}, _from_pid, players) do
    {:stop, :normal, {:ok, "Stopped"}, players}
  end

  def handle_call({:player_count}, _from_pid,  players) do
    {:reply, {:ok, length(Node.list)}, players}
  end

  def handle_call({:register, player_name}, {from_pid, _}, players) do
    Logger.info("Registered #{inspect from_pid}: #{player_name}")
    players = Map.merge(players, %{player_name => from_pid})
    {:reply, {:ok, "Now there are #{players |> Map.keys |> length} players"}, players}
  end

  def handle_call({:registered_players}, _from_pid, players) do
    {:reply, {:ok, players}, players}
  end

  def handle_call(message, _from_pid, players) do
    Logger.warn("Players message not supported: #{inspect message}")
    {:noreply, players}
  end

end

