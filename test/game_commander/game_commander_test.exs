defmodule GameCommanderTest do
  use ExUnit.Case

  def mock_phase(context) do
    Map.update(context, :count, 1, &(&1 + 1))
  end

  describe "game ticks" do
    test "a tick counter can be maintained" do
      context =
        List.duplicate(&GameCommanderTest.mock_phase/1, 3)
        |> GameCommander.start()

      assert context.count == 3
    end
  end

  describe "wait for players" do
    
    test "a player connects" do
      context = GameCommander.start([&GameCommanderTest.mock_phase/1])

      assert context.count == 1
      assert context.state == :start_game
    end
  end

  describe "start game" do

    test "notify players of game start" do
      context = GameCommander.start([&GameCommanderTest.mock_phase/1], %{state: :start_game})

      assert context.count == 1
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

