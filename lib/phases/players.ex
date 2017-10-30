defmodule Players do
  require Logger

  def start() do
    pid = spawn_link(Players.Server, :loop, [:continue, %{}])

    :global.register_name(:players, pid)

    pid
  end

  def stop(pid) do
    send pid, :stop
  end

  def player_count(pid) do
    player_request(pid, [:player_count])
  end

  def register(pid, player_name) do
    player_request(pid, [:register, player_name])
  end

  def registered_players(pid) do
    player_request(pid, [:registered_players])
  end

  defp player_request(pid, message) do
    send pid, List.to_tuple(message ++ [self()])
    receive do
      {:ok, value} -> {:ok, value}
      unexpected   -> Logger.error("Player response unexpected: #{inspect unexpected}")
    after
      1_000 -> 
        Logger.warn("Player process did not respond")
        -1
    end
  end

end

defmodule Players.Server do
  require Logger

  def loop(:stop, _) do end
  def loop(:continue, players) do
    {next, players } = receive do
      command -> run(command, players)
    end

    loop(next, players)
  end

  defp run({:stop, _ }, players) do
    {:stop, players}
  end

  defp run({:player_count, from_pid }, players) do
    send from_pid, {:ok, length(Node.list)}
    {:continue, players }
  end

  defp run({:register, player_name, from_pid}, players) do
    players = Map.merge(players, %{player_name => from_pid})
    send from_pid, {:ok, "Now there are #{players |> Map.keys |> length} players"}
    {:continue, players }
  end

  defp run({:registered_players, from_pid}, players) do
    send from_pid, {:ok, players}
    {:continue, players }
  end

  defp run(message, players) do
    Logger.warn("Players message not supported: #{inspect message}")
    {:continue, players }
  end

end

