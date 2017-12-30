defmodule Mix.Tasks.Battleship.TakeTurn do
  use Mix.Task

  @shortdoc "Try to bomb a ship"

  def run(name) when length(name) == 0 do
    IO.puts "usage: take_turn <name> <x> <y>" 
  end
  def run([name, x, y]) do
    {x, _} = Integer.parse(x)
    {y, _} = Integer.parse(y)

    Battleship.Command.puts(:turns, fn pid ->
      {:ok, Turns.take(pid, name, %{x: x, y: y}) }
    end)
  end
end

