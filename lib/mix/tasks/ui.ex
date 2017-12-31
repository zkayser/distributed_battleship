defmodule Mix.Tasks.Battleship.Ui do
  use Mix.Task

  @shortdoc "UI showing the battleship game"

  def run([]) do
    Battleship.Command.command(:ocean, fn pid ->
      Ui.loop(pid)

      {:ok, "UI Finished"}
    end)
  end
end

