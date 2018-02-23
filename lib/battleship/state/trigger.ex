defmodule Trigger do

  def start() do
    state = false

    {:ok, pid} = GenServer.start_link(Trigger.Server, state, name: {:global, :trigger})
    pid
  end

  def stop(), do: stop(:global.whereis_name(:trigger))
  def stop(:undefined), do: {:ok, "Already Stopped"}
  def stop(pid) do
    case Process.alive?(pid) do
      true  -> GenServer.call(pid, {:stop})
      false -> {:ok, "Aleady Stopped"}
    end
  end


  def pulled?(pid) do
    GenServer.call(pid, {:pulled})
  end

  def pull(pid) do
    GenServer.call(pid, {:pull})
  end
end

defmodule Trigger.Server do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def handle_call({:pulled}, _rom_pid, state) do
    {:reply, state, false}
  end

  def handle_call({:pull}, _rom_pid, _tate) do
    {:reply, true, true}
  end

  def handle_call({:stop}, _from_pid, state) do
    {:stop, :normal, {:ok, "Stopped"}, state}
  end
end
