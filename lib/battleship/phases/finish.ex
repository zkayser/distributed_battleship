defmodule Finish do

  require Logger

  def tick(%{notified: true}) do
    # Do nothing.

    Logger.info("GAME OVER.")
  end

  def tick(phase_context = %{service: %{players_pid: players_pid, ocean_pid: ocean_pid}}) do
    {:ok, registered_players} = Players.registered_players(players_pid)
    {:ok, ships} = Ocean.ships(ocean_pid)

    winners_ships = Ships.floating(ships)
    winning_ship = List.first(winners_ships)

    Logger.debug("Final ship state #{inspect ships}")
    Logger.info("Game over. Winner is '#{winning_ship.player}'")

    for players_pid <- Map.values(registered_players) do
      Logger.info("Notifying players. Winner is '#{winning_ship.player}'")
      send players_pid, {:game_over, winner: winning_ship.player}
    end

    Map.merge(phase_context, %{notified: true})
  end
end
