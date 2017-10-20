defmodule WaitingForPlayersTest do
  use ExUnit.Case

  test "get some players" do
    context = WaitingForPlayers.tick(%{})

    assert Enum.count(context.players) == 1
  end

  test "start players node" do
    
  end
  
end

