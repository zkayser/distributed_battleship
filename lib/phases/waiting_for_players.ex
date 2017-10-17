defmodule WaitingForPlayers do

  def run(context) do
    Map.merge(context, %{players: [1]})
  end
end
