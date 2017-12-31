defmodule Buster do
  def start(player) do
    with true             <- connect(),
        {:ok, _essage}    <- register(player),
        {:ok, ocean_size} <- wait_for_congratulations(),
        {:ok, _dded}      <- add_ship(player, ocean_size),
        {:ok, _anything}  <- listen_for_turns()
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
    IO.gets("Add a ship?")

    ocean_pid = :global.whereis_name(:ocean)
    result = GenServer.call(ocean_pid, {:add_ship, %{
          player: player,
          from: %{
            from_x: 1,
            from_y: 2
          },
          to: %{
            to_x: 3,
            to_y: 2
          }
        }
      }
    )
 
    IO.inspect(result)

    result
  end

  defp listen_for_turns() do
    IO.puts "Waiting for turns"

    listen_for_turns_loop()
  end

  defp listen_for_turns_loop() do
    receive do
      message -> 
        IO.puts("")
        IO.inspect(message)
    after 
      5000 -> IO.write(".")
    end

    listen_for_turns_loop()
  end
end
