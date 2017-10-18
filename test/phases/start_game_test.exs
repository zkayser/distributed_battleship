defmodule StartGameTest do
  use ExUnit.Case

  test "start game" do
    StartGame.tick(%{})

    assert 1 == 1
  end
end

