defmodule Finish do

  def tick(phase_context = %{notified: true}) do
    # Do nothing.
  end

  def tick(phase_context = %{service: %{players_pid: players_pid, ocean_pid: ocean_pid}}) do
    {:ok, registered_players} = Players.registered_players(players_pid)
    {:ok, ships} = Ocean.ships(ocean_pid)

    winners_ships = Ships.floating(ships)
    winning_ship = List.first(winners_ships)

    for players_pid <- Map.values(registered_players) do
      IO.puts("Game over. #{inspect players_pid}. Winner is '#{winning_ship.player}'")
      send players_pid, {:game_over, winner: winning_ship.player}
    end

    Map.merge(phase_context, %{notified: true})
  end
end
