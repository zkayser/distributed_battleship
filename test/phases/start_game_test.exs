defmodule StartGameTest do
  use ExUnit.Case

  setup do
    players_pid = Players.start()

    on_exit fn -> Players.stop() end

    [players_pid: players_pid]
  end

  test "start game", context do
    phase_context = 
      %{service: %{players_pid: context.players_pid}}
      |> StartGame.tick()

    assert phase_context.registered_players == %{}
  end

  test "add player", context do
    Players.register(context[:players_pid], "Bob")

    phase_context = 
      %{service: %{players_pid: context.players_pid}}
      |> StartGame.tick()

    assert %{"Bob" => self()} == phase_context.registered_players
    assert phase_context.new_phase == :adding_ships
    assert phase_context.ocean_size == 1 * 10
  end

  test "sends messages to player nodes", context do
    Players.register(context[:players_pid], "Bob")

    %{service: %{players_pid: context.players_pid}}
    |> StartGame.tick()

    assert_receive {"congratulations", 10, 20}
  end

  test "sends messages to multiple player nodes", context do
    Players.register(context[:players_pid], "Bob")
    Players.register(context[:players_pid], "Frank")

    %{service: %{players_pid: context.players_pid}}
    |> StartGame.tick()

    assert_receive {"congratulations", 20, 20}
    assert_receive {"congratulations", 20, 20}
  end
end

