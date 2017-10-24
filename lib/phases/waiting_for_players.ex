defmodule WaitingForPlayers do
  @moduledoc """
  * Once the Game Commander is started players will have 60s to start their player and connect.
  * Players connect and send in their details.
  """

  require Logger

  def tick(phase_context = %{players_pid: pid, wait_start: wait_start, wait_max: wait_max}) do
    {:ok, player_count} = Players.player_count(pid)
    {:ok, registered_players} = Players.registered_players(pid)

    phase_context = Map.merge(phase_context, %{
      new_phase: :waiting_for_players,
      player_count: player_count,
      registered_players: registered_players
    })

    phase_context = cond do
      DateTime.diff(DateTime.utc_now, wait_start) >= wait_max -> Map.merge(phase_context, %{new_phase: :start_game})
      true -> phase_context
    end

    phase_context
  end

  def tick(phase_context) do
    pid = Players.start()

    new_phase_context = %{
      new_phase: :waiting_for_players,
      players_pid: pid,
      player_count: 0,
      wait_max: 60,
      wait_start: DateTime.utc_now
    }

    Map.merge(new_phase_context, phase_context)
  end
end
