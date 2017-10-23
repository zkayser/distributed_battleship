defmodule WaitingForPlayersTest do
  use ExUnit.Case

  test "initialize the players tracking data" do
    phase_context = %{}
              |> WaitingForPlayers.tick()

    Players.stop(phase_context.players_pid)

    assert phase_context.new_phase == :waiting_for_players
    assert phase_context.player_count == 0
  end

  test "get players count after a number of ticks" do
    phase_context = %{}
              |> WaitingForPlayers.tick()
              |> WaitingForPlayers.tick()
              |> WaitingForPlayers.tick()
              |> WaitingForPlayers.tick()

    Players.stop(phase_context.players_pid)

    assert phase_context.new_phase == :waiting_for_players
    assert phase_context.player_count == 0
  end

  test "when ticks hits 60s stop waiting for players" do
    phase_context = %{wait_max: 0}
              |> WaitingForPlayers.tick()
              |> WaitingForPlayers.tick()

    Players.stop(phase_context.players_pid)

    assert phase_context.new_phase == :start_game
    assert phase_context.player_count == 0
  end
end

