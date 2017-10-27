defmodule Mix.Tasks.Battleship.RegisteredPlayers do
  use Mix.Task
  
  require Players

  @shortdoc "A list of registered players"

  def run(_) do
    Battleship.Command.command(fn pid ->
      Players.registered_players(pid)
    end)
  end
end
