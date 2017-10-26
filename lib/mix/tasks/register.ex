defmodule Mix.Tasks.Battleship.Register do
  use Mix.Task

  @shortdoc "A player registers for the battleships game"

  def run(name) do
    IO.puts "Player #{name} registering."

    {:ok, hostname} = :inet.gethostname
    connected = Node.connect :"commander@#{hostname}"
    IO.puts(">>>> Connected #{connected}")

    :timer.sleep(1000)

    pid = :global.whereis_name(:players)
    IO.puts(">>>> players pid #{inspect pid}")

    players = Players.register(pid, name)
    IO.puts(">>>> #{inspect players}")
  end
end
