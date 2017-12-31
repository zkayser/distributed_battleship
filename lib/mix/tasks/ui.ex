defmodule Mix.Tasks.Battleship.Ui do
  use Mix.Task

  @shortdoc "UI showing the battleship game"

  def run([]) do
    Battleship.Command.command(:ocean, fn pid ->
      {:ok, ships} = Ocean.ships(pid)
      ocean = Ui.render(:text, 10, %{ships: ships})

      IO.write(ocean)

      {:ok, ships }
    end)
  end
end

