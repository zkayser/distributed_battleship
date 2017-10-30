defmodule StartGame do
  @moduledoc "Players are told its time to start with the ocean size, and the number of ship compoents they can use."

  def tick(phase_context) do
  	{:ok, registered_players} = Players.registered_players(players_pid)
    Map.merge(phase_context, %{registered_players: registered_players})
  end

  defp players_pid do
  	:global.whereis_name(:players)
  end
end

