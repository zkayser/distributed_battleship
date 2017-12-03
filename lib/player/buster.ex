defmodule Buster do
  def start() do
    with true <- connect(),
        {:ok, message} <- register(),
        {:ok, ocean_size} <- wait_for_congratulations(),
        {:ok, added} <- add_ship(ocean_size)
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

  defp register() do
    IO.gets("Register a player?")

    :timer.sleep(1000)
    players_pid = :global.whereis_name(:players)
    GenServer.call(players_pid, {:register, "Buster"})
  end

  def wait_for_congratulations() do
    IO.gets("Wait to learn the size of the ocean")

    receive do
      {"congratulations", ocean_size, max_ship_parts} -> 
        IO.puts(">>>> Ocean Size: #{ocean_size}")
        IO.puts(">>>> Max Ship Parts: #{max_ship_parts}")
        {:ok, ocean_size}
      anything_else -> 
        {:error, "Oops: #{inspect anything_else}"}
    after
      1000 -> 
        {:error, ">>>> Oops: Timeout, No message about ocean size"}
    end

  end

  defp add_ship(ocean_size) do
    IO.gets("Add a ship?")

    ocean_pid = :global.whereis_name(:ocean)
    GenServer.call(ocean_pid, {:add_ship, %{
          player: "Buster",
          from: %{
            from_x: 1,
            from_y: 10
          },
          to: %{
            to_x: 10,
            to_y: 10
          }
        }
      }
    )
  end
end
