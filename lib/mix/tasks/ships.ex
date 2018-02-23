defmodule Mix.Tasks.Battleship.Ships do
  use Mix.Task

  @shortdoc "List all registered ships"

  def run(commander_ip) do
    Battleship.Command.puts(commander_ip, :ocean, fn pid ->
      {:ok, Ocean.ships(pid) }
    end)
  end
end

