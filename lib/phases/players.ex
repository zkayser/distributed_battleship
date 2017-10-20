defmodule Players do

  def start() do
    spawn_link(__MODULE__, :wait_for_players, [:continue, %{}])
  end

  def stop(pid) do
    send pid, :stop
  end

  def player_count(pid) do
    send pid, {:player_count, self()}
    receive do
      player_count -> player_count
    after
      1_000 -> 
        IO.puts(">>>> player count did not respond")
        -1
    end
  end

  def wait_for_players(:stop, _) do end
  def wait_for_players(:continue, players) do
    receive do
      {:stop, _ } -> :stop
      {:player_count, from_pid } -> 
        send from_pid, 0
        :continue
      message -> 
        IO.puts(">>>> wait_for_players #{inspect message}")
        :continue
    end
    |> wait_for_players(players)
  end

end

