defmodule Mix.Tasks.Battleship.Ui do
  use Mix.Task

  @shortdoc "UI showing the battleship game"

  def run([]) do
    Battleship.Command.command(:ocean, fn pid ->
      {:ok, Ocean.strikes(pid) }
    end)
  end
end

