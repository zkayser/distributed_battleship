defmodule Mix.Tasks.Battleship.AddShip do
  use Mix.Task

  @shortdoc "Adds a ship for a player"

  def run(name) when length(name) == 0 do
    IO.puts "usage: add_ship <name> <from x> <from y> <to x> <to y>" 
  end
  def run([name, from_x, from_y, to_x, to_y]) do
    Battleship.Command.puts(:ocean, fn pid ->
      {:ok, Ocean.add_ship(pid, name, from_x, from_y, to_x, to_y) }
    end)
  end
end

