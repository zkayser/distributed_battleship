defmodule WaitingForPlayers do
  @moduledoc """
  * Once the Game Commander is started players will have 60s to start their player and connect.
  * Players connect and send in their details.
  """

  require Logger

  def tick(phase_context = %{service: %{players_pid: players_pid, trigger_pid: trigger_pid}}) do
    {:ok, player_count} = Players.player_count(players_pid)
    {:ok, registered_players} = Players.registered_players(players_pid)

    phase_context = Map.merge(phase_context, %{
      player_count: player_count,
      registered_players: registered_players
    })

    Phase.change?(trigger_pid, phase_context, :start_game)
  end

  def tick(phase_context) do
    new_phase_context = %{
      player_count: 0,
    }

    Map.merge(new_phase_context, phase_context)
  end
end

