defmodule StartGameTest do
  use ExUnit.Case

  test "start game" do
    StartGame.tick(GameCommander.new())

    assert 1 == 1
  end
end

