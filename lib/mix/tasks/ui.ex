defmodule Mix.Tasks.Battleship.Ui do
  use Mix.Task

  @shortdoc "UI showing the battleship game"

  def run([commander_ip, visibility]) do
    visibility = visibility |> to_string |> String.to_atom

    Battleship.Command.command(commander_ip, :ocean, fn pid ->
      Ui.start(pid, visibility)

      {:ok, "UI Finished"}
    end)
  end
end

