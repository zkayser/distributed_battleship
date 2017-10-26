defmodule Mix.Tasks.Battleship.Register do
  use Mix.Task

  @shortdoc "A player registers for the battleships game"

  def run(name) do
    IO.puts "Player #{name} registering."
  end
end
