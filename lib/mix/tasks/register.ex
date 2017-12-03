defmodule Mix.Tasks.Battleship.Register do
  use Mix.Task

  @shortdoc "A player registers for the battleships game"

  def run(name) when length(name) == 0 do
    IO.puts "usage: register <name>" 
  end
  def run(name) do
    Battleship.Command.command(:players, fn pid ->
      {:ok, Players.register(pid, name) }
    end)
  end
end

