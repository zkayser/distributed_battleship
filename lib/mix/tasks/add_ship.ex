defmodule Mix.Tasks.Battleship.AddShip do
  use Mix.Task

  @shortdoc "Adds a ship for a player"

  def run(name) when length(name) == 0 do
    IO.puts "usage: add_ship <name> <from lat> <from long> <to lat> <to long>" 
  end
  def run([name, from_lat, from_long, to_lat, to_long]) do
    Battleship.Command.command(:ocean, fn pid ->
      Ocean.add_ship(pid, name, from_lat, from_long, to_lat, to_long)
    end)
  end
end

