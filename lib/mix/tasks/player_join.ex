defmodule Mix.Tasks.Battleship.Join do
  use Mix.Task

  @shortdoc "A player joins the battleships game"

  def run(name) do
    IO.puts "Player #{name} joining."
  end
end
