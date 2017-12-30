defmodule Mix.Tasks.Battleship.Ui do
  use Mix.Task

  @shortdoc "UI showing the battleship game"

  def run([]) do
    Battleship.Command.command(:ocean, fn pid ->
      strikes = Ocean.strikes(pid)
      Ui.render(:text, %{strikes: strikes})

      {:ok, strikes }
    end)
  end
end

