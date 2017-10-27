defmodule Mix.Tasks.Battleship.Register do
  use Mix.Task

  @shortdoc "A player registers for the battleships game"

  require Battleship.Command

  def run(name) when length(name) == 0 do
    IO.puts "usage: register <name>" 
  end
  def run(name) do
    Battleship.Command.command(fn pid ->
      Players.register(pid, name)
    end)
  end
end

