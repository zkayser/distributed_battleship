defmodule Players do
  require Logger

  def start() do
    pid = spawn_link(Players.Server, :wait_for_players, [:continue, %{}])

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

  def wait_for_players(:stop, _) do end
  def wait_for_players(:continue, players) do
    {next, players } = receive do
      {:stop, _ } -> 
        {:stop, players}
      {:player_count, from_pid } -> 
        send from_pid, {:ok, length(Node.list)}
        {:continue, players }
      {:register, player_name, from_pid} ->
        players = Map.merge(players, %{player_name => true})
        send from_pid, {:ok, "Now there are #{players |> Map.keys |> length} players"}
        {:continue, players }
      {:registered_players, from_pid} ->
        send from_pid, {:ok, Map.keys(players)}
        {:continue, players }
      message -> 
        IO.puts(">>>> wait_for_players #{inspect message}")
        {:continue, players }
    end

    wait_for_players(next, players)
  end

end

