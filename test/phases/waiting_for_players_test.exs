defmodule WaitingForPlayersTest do
  use ExUnit.Case

  test "initialize the players tracking data" do
    context = %{}
              |> WaitingForPlayers.tick()

    Players.stop(context.waiting_for_players.players_pid)

    assert context.new_state == :waiting_for_players
    assert context.waiting_for_players.player_count == 0
  end

  test "get players count after a number of ticks" do
    context = %{}
              |> WaitingForPlayers.tick()
              |> WaitingForPlayers.tick()
              |> WaitingForPlayers.tick()
              |> WaitingForPlayers.tick()

    Players.stop(context.waiting_for_players.players_pid)

    assert context.new_state == :waiting_for_players
    assert context.waiting_for_players.player_count == 0
  end

  test "when ticks hits 60s stop waiting for players" do
    context = %{waiting_for_players: %{wait_max: 0}}
              |> WaitingForPlayers.tick()
              |> WaitingForPlayers.tick()

    Players.stop(context.waiting_for_players.players_pid)

    assert context.new_state == :start_game
    assert context.waiting_for_players.player_count == 0
  end
end

