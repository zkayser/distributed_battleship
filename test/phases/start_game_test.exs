defmodule StartGameTest do
  use ExUnit.Case

  setup do
  	players_pid = Players.start()

  	on_exit fn -> Players.stop(players_pid) end

  	[players_pid: players_pid]
  end

  test "start game", context do
    phase_context = StartGame.tick(%{})

    assert phase_context.registered_players == %{}
  end

  test "add player", context do
  	Players.register(context[:players_pid], "Bob")

  	phase_context = StartGame.tick(%{})

  	assert %{"Bob" => self()} == phase_context.registered_players
  end
end

