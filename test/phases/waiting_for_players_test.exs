defmodule WaitingForPlayersTest do
  use ExUnit.Case

  setup() do
    players_pid = Players.start()

    on_exit(fn -> Players.stop() end)

    [players_pid: players_pid]
  end

  test "initialize the players tracking data", context do
    phase_context = 
      %{service: %{players_pid: context.players_pid}}
      |> WaitingForPlayers.tick()

    assert phase_context.player_count == 0
  end

  test "get players count after a number of ticks", context do
    phase_context = 
      %{service: %{players_pid: context.players_pid}}
      |> WaitingForPlayers.tick()
      |> WaitingForPlayers.tick()
      |> WaitingForPlayers.tick()
      |> WaitingForPlayers.tick()

    assert phase_context.player_count == 0
  end

  test "when ticks hits 60s stop waiting for players", context do
    phase_context = 
      %{wait_max: 0, service: %{players_pid: context.players_pid}}
      |> WaitingForPlayers.tick()
      |> WaitingForPlayers.tick()

    assert phase_context.new_phase == :start_game
    assert phase_context.player_count == 0
    assert phase_context.registered_players == %{}
  end
end

