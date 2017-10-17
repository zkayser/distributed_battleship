defmodule GameCommanderTest do
  use ExUnit.Case

  describe "wait for players" do
    
    test "a player connects" do
      phases = [&GameCommander.wait_for_players/1]

      context = GameCommander.start(phases)

      assert context.state == :start_game
      assert Enum.count(context.players) == 1
    end
  end

  describe "start game" do

    test "notify players of game start" do
      phases = [
        &GameCommander.wait_for_players/1,
        &GameCommander.start_game/1
      ]
      
      context = GameCommander.start(phases)

      assert context.state == :adding_ships
    end
    
  end

  describe "players adding ships" do
  end

  describe "players taking a turn" do
  end

  describe "players getting feedback" do
  end

  describe "scoreboard" do
  end

end

