defmodule WaitingForPlayersTest do
  use ExUnit.Case

  test "get some players" do
    context = WaitingForPlayers.run(GameCommander.new())

    assert context.state == :start_game
    assert Enum.count(context.players) == 1
  end
end

