defmodule StartGame do
  @moduledoc "Players are told its time to start with the ocean size, and the number of ship compoents they can use."

  def tick(phase_context = %{service: %{players_pid: players_pid}}) do
    {:ok, registered_players} = Players.registered_players(players_pid)

    ocean_size = notify_players(registered_players)

    Map.merge(phase_context, %{registered_players: registered_players, new_phase: :adding_ships, ocean_size: ocean_size})
  end

  defp notify_players(registered_players) do
    ocean_size = Enum.count(Map.keys(registered_players)) * 10

    for players_pid <- Map.values(registered_players) do
      send players_pid, {"congratulations", ocean_size, 20}
    end

    ocean_size
  end
end

