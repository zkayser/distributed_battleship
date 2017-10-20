defmodule WaitingForPlayers do
  @moduledoc """
  * Once the Game Commander is started players wil have 60s to start their player and connect.
  """

  def tick(context) do
    initialize(context)

    Map.merge(context, %{players: [1]})
  end

  defp initialize(context = %{wait_for_players: player_count}) do

  end

  # With no context for this state we need to startup the Node ready to accept players.
  defp initialize(context) do
    Players.start()
  end
end
