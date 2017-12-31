defmodule Mix.Tasks.Battleship.Ui do
  use Mix.Task

  @shortdoc "UI showing the battleship game"

  def run([]) do
    Battleship.Command.command(:ocean, fn pid ->
      ships = Ocean.ships(pid)
      Ui.render(:text, 10, %{ships: ships})

      {:ok, ships }
    end)
  end
end

