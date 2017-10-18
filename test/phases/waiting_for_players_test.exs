defmodule WaitingForPlayersTest do
  use ExUnit.Case

  test "get some players" do
    context = WaitingForPlayers.tick(GameCommander.new())

    assert Enum.count(context.players) == 1
  end
end

