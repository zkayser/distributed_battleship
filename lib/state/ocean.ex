defmodule Ocean do
  require Logger

  def start() do
    pid = spawn_link(Ocean.Server, :loop, [:continue, %{ships: []}])

    :global.register_name(:ocean, pid)

    pid
  end

  def stop(), do: stop(:global.whereis_name(:ocean))
  def stop(pid) do
    send pid, {:stop, self()}
  end

  def ships(pid) do
    ocean_request(pid, [:ships])
  end

  def add_ship(pid, from_lat, from_long, to_lat, to_long) do
    ocean_request(pid, [:add_ship, from_lat, from_long, to_lat, to_long])
  end

  defp ocean_request(pid, message) do
    send pid, List.to_tuple(message ++ [self()])
    receive do
      {:ok, value} -> {:ok, value}
      unexpected   -> Logger.error("Ocean response unexpected: #{inspect unexpected}")
    after
      1_000 -> 
        Logger.warn("Ocean process did not respond")
        -1
    end
  end
end

defmodule Ocean.Server do
  require Logger

  def loop(:stop, _) do end
  def loop(:continue, state) do
    {next, state } = receive do
      command -> 
        Logger.debug("Ocean Message: #{inspect command}")
        run(command, state)
    end

    loop(next, state)
  end

  defp run({:stop, from_pid}, state) do
    send from_pid, {:ok, "Stopped"}
    {:stop, state}
  end

  defp run({:ships, from_pid}, state) do
    send from_pid, {:ok, state.ships}
    {:continue, state}
  end

  defp run({:add_ship, from_lat, from_long, to_lat, to_long, from_pid}, state) do
    state = Map.merge(state, %{ships: state.ships ++ [{from_lat, from_long, to_lat, to_long}]})
    send from_pid, {:ok, "Added"}
    {:continue, state}
  end

  defp run(command, state) do
    Logger.info("Invalid command #{inspect command} : #{inspect state}")
    {:continue, state}
  end

end

