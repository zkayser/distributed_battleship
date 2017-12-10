defmodule Turns do
  def start() do
    {:ok, pid} = GenServer.start_link(Turns.Server, [], name: {:global, :turns})
    pid
  end

  def stop(), do: stop(:global.whereis_name(:turns))
  def stop(:undefined), do: {:ok, "Already Stopped"}
  def stop(pid) do
    case Process.alive?(pid) do
      true  -> GenServer.call(pid, {:stop})
      false -> {:ok, "Aleady Stopped"}
    end
  end

  def take(pid, player, position) do
    GenServer.call(pid, {:take, player, position})
  end

  def get(pid) do
    {:ok, turns} = GenServer.call(pid, {:get})

    turns
  end
end

defmodule Turns.Server do
  use GenServer

  def handle_call({:take, player, position}, _rom_pid, state) do
    {:reply, {:ok}, [state || {player, position}]}
  end

  def handle_call({:get}, _rom_pid, state) do
    {:reply, {:ok, state}, []}
  end

  def handle_call({:stop}, _from_pid, state) do
    {:stop, :normal, {:ok, "Stopped"}, state}
  end
end

