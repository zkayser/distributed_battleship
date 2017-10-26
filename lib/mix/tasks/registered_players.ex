defmodule Mix.Tasks.Battleship.RegisteredPlayers do
  use Mix.Task
  
  require Players

  @shortdoc "A list of registered players"

  def run(_) do
    IO.puts "Registered Players"

    {:ok, hostname} = :inet.gethostname
    connected = Node.connect :"commander@#{hostname}"
    IO.puts(">>>> Connected #{connected}")

    :timer.sleep(1000)

    pid = :global.whereis_name(:players)
    IO.puts(">>>> players pid #{inspect pid}")

    players = Players.registered_players(pid)
    IO.puts(">>>> registered players #{inspect players}")

  end
end
