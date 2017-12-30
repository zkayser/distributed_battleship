defmodule Mix.Tasks.Battleship.Ships do
  use Mix.Task

  @shortdoc "List all registered ships"

  def run(_) do
    Battleship.Command.puts(:ocean, fn pid ->
      {:ok, Ocean.ships(pid) }
    end)
  end
end

