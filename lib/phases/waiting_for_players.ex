defmodule WaitingForPlayers do

  def run(context) do
    Map.merge(context, %{state: :start_game, players: [1]})
  end
end
