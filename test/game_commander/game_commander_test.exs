defmodule GameCommanderTest do
  use ExUnit.Case

  describe "wait for players" do
    
    test "a player connects" do
      phases = [&WaitingForPlayers.run/1]

      context = GameCommander.start(phases)

      assert context.state == :start_game
    end
  end

  describe "start game" do

    test "notify players of game start" do
      phases = [&StartGame.run/1]
      
      context = GameCommander.start(phases, %{state: :start_game})

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

