defmodule Mix.Tasks.Battleship.RegisteredPlayers do
  use Mix.Task
  
  require Players

  @shortdoc "A list of registered players"

  def run(commander_ip) do
    Battleship.Command.puts(commander_ip, :players, fn pid ->
      {:ok, Players.registered_players(pid) }
    end)
  end
end
