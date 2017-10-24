defmodule Players do

  def start() do
    pid = spawn_link(Players.Server, :wait_for_players, [:continue, %{}])

    :global.register_name(:players, pid)

    pid
  end

  def stop(pid) do
    send pid, :stop
  end

  def player_count(pid) do
    send pid, {:player_count, self()}
    receive do
      {:ok, player_count} -> {:ok, player_count}
    after
      1_000 -> 
        IO.puts(">>>> cant get player count, player count did not respond")
        -1
    end
  end

  def register(pid, player_name) do
    send pid, {:register, player_name, self()}
    receive do
      {:ok}   -> {:ok}
      message -> {:error, message}
    after
      1_000 -> 
        IO.puts(">>>> can't register, player count did not respond")
        -1
    end
  end

  def registered_players(pid) do
    send pid, {:registered_players, self()}
    receive do
      {:ok, players}     -> {:ok, players}
      message            -> {:error, message}
    after
      1_000 -> 
        IO.puts(">>>> can't get registerd playres, player count did not respond")
        -1
    end
  end
end

defmodule Players.Server do

  def wait_for_players(:stop, _) do end
  def wait_for_players(:continue, players) do
    next = receive do
      {:stop, _ } -> :stop
      {:player_count, from_pid } -> 
        send from_pid, {:ok, length(Node.list)}
        :continue
      {:register, player_name, from_pid} ->
        players = Map.merge(players, %{player_name => true})
        send from_pid, {:ok}
        :continue
      {:registered_players, from_pid} ->
        send from_pid, {:ok, Map.keys(players)}
        :continue
      message -> 
        IO.puts(">>>> wait_for_players #{inspect message}")
        :continue
    end

    wait_for_players(next, players)
  end

end

