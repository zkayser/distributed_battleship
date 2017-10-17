defmodule StartGameTest do
  use ExUnit.Case

  test "start game" do
    context = StartGame.run(GameCommander.new())
    
    assert context.state == :adding_ships
  end
end

