defmodule Turns do
  def start() do
    {:ok, pid} = GenServer.start_link(Turns.Server, %{active: false, turns: []}, name: {:global, :turns})
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

  def activate(pid) do
    GenServer.call(pid, {:activate})
  end

  def deactivate(pid) do
    GenServer.call(pid, {:deactivate})
  end

  def is_active(pid) do
    {:ok, active} = GenServer.call(pid, {:is_active})

    active
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

  def handle_call(command, _from_pid, state = %{active: false}) when elem(command, 0) not in [:activate, :is_active, :stop] do
    {:reply, {:error, "No turns accepted yet"}, state}
  end

  def handle_call({:is_active}, _from_pid, state) do
    {:reply, {:ok, state.active}, state}
  end

  def handle_call({:activate}, _, state) do
    {:reply, {:ok, "Activated"}, Map.merge(state, %{active: true}) }
  end

  def handle_call({:deactivate}, _, state) do
    {:reply, {:ok, "Deactivated"}, Map.merge(state, %{active: false}) }
  end

  def handle_call({:take, _layer, %{x: x, y: y}}, _rom_pid, state) when not is_number(x) or not is_number(y) do
    {:reply, {:error, "position must be numeric"}, state}
  end
  def handle_call({:take, player, position}, _rom_pid, state) do
    {:reply, {:ok}, Map.merge(state, %{turns: state.turns ++ [{player, position}] }) }
  end

  def handle_call({:get}, _rom_pid, state) do
    {:reply, {:ok, state.turns}, Map.merge(state, %{turns: []})}
  end

  def handle_call({:stop}, _from_pid, state) do
    {:stop, :normal, {:ok, "Stopped"}, state}
  end
end

