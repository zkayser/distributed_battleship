defmodule Finish do

  require Logger

  def tick(phase_context = %{notified: true}) do
    # Do nothing.

    Logger.info("GAME OVER.")

    Map.merge(phase_context, %{game_over: true})
  end

  def tick(phase_context = %{service: %{players_pid: players_pid, ocean_pid: ocean_pid}}) do
    {:ok, registered_players} = Players.registered_players(players_pid)
    {:ok, ships} = Ocean.ships(ocean_pid)

    notify_players(phase_context, registered_players, ships)
  end

  defp notify_players(phase_context, registered_players, ships) do
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
