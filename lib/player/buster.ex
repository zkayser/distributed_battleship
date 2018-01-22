defmodule Buster do
  def start(player) do
    with true             <- connect(),
        {:ok, _essage}    <- register(player),
        {:ok, ocean_size} <- wait_for_congratulations(),
        {:ok, _dded}      <- add_ship(player, ocean_size),
        {:ok, _anything}  <- take_turns(player, ocean_size)
    do
      IO.puts(">>>> FINISHED")
    else
      {:error, message} -> IO.puts("ERROR: #{message}")
      message           -> IO.inspect(message) 
    end

  end

  defp connect() do
    IO.gets("Ready to connect?")

    {:ok, hostname} = :inet.gethostname
    Node.connect(:"commander@#{hostname}")
  end

  defp register(player) do
    IO.gets("Register a player? #{player}")

    :timer.sleep(1000)
    players_pid = :global.whereis_name(:players)
    GenServer.call(players_pid, {:register, player})
  end

  def wait_for_congratulations() do
    IO.puts("Waiting to hear about the size of the ocean")
    wait_for_message()
  end

  defp wait_for_message() do
    receive do
      {"congratulations", ocean_size, max_ship_parts} -> 
        IO.puts("")
        IO.puts(">>>> Ocean Size: #{ocean_size}")
        IO.puts(">>>> Max Ship Parts: #{max_ship_parts}")
        {:ok, ocean_size}
      anything_else -> 
        IO.puts("")
        IO.inspect {:error, "Oops: #{inspect anything_else}"}
        :timer.sleep(5000)
        wait_for_message()
    after
      5000 -> 
        IO.write(".")
        wait_for_message()
    end
  end

  defp add_ship(player, _cean_size) do
    positions = IO.gets("Add a ship? from_x from_y to_x to_y: ")
    positions = String.split(positions)
    [from_x, from_y, to_x, to_y] = Enum.map(positions, &(String.to_integer(&1)))

    ocean_pid = :global.whereis_name(:ocean)
    result = GenServer.call(ocean_pid, {:add_ship, %{
          player: player,
          from: %{
            from_x: from_x,
            from_y: from_y
          },
          to: %{
            to_x: to_x,
            to_y: to_y
          }
        }
      }
    )
 
    IO.inspect(result)

    result
  end

  defp take_turns(player, ocean_size) do
    IO.puts "Waiting for turns"

    turns_pid = :global.whereis_name(:turns)

    listen_for_turns_loop(turns_pid, player, ocean_size, "", take_a_turn: true, playing: true)
  end

  defp listen_for_turns_loop(_turns_pid, _player, _ocean_size, last_message, take_a_turn: _take_a_turn, playing: false), do: last_message
  defp listen_for_turns_loop(turns_pid, player, ocean_size, last_message, take_a_turn: true, playing: playing) do
    turns = IO.gets("Your turn: ocean is #{ocean_size}x#{ocean_size}, or enter to read messages (x y): ")
    process_turn(turns, player, turns_pid)

    listen_for_turns_loop(turns_pid, player, ocean_size, last_message, take_a_turn: false, playing: playing)
  end

  defp listen_for_turns_loop(turns_pid, player, ocean_size, _last_message, take_a_turn: false, playing: true) do
    {last_message, take_a_turn, playing} = listen_to_other_players_turns()

    listen_for_turns_loop(turns_pid, player, ocean_size, last_message, take_a_turn: take_a_turn, playing: playing)
  end

  defp process_turn("", _, _), do: false
  defp process_turn("\n", _, _), do: false
  defp process_turn(turns, player, turns_pid) do
    turns = String.split(turns)
    [x, y] = Enum.map(turns, &(String.to_integer(&1)))

    result = GenServer.call(turns_pid, {:take, player, %{x: x, y: y}})

    IO.inspect(result)
  end

  defp listen_to_other_players_turns() do
    receive do
      message = {:game_over, winner: name} ->
        IO.puts "GAME OVER"
        IO.puts "Winner: #{name}"
        {message, false, false}
      message -> 
        IO.puts("")
        IO.inspect(message)
        {message, false, true}
    after 
      5000 -> IO.write(".")
      {"none", true, true}
    end
  end
end

