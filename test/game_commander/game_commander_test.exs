defmodule GameCommanderTest do
  use ExUnit.Case

  def fake_tick(context) do
    Map.merge(context, %{new_state: hd(context.states), states: tl(context.states)})
  end

  describe "tick" do
    test "trigger an action on a tick" do
      context = GameCommander.start(:none, %{states: [:finish]}, [none: &GameCommanderTest.fake_tick/1])

      assert context.tick_count == 1
    end

    test "run two ticks" do
      states = [
        none: &GameCommanderTest.fake_tick/1,
        finish: &GameCommanderTest.fake_tick/1
      ]

      context = GameCommander.start(:none, %{states: [:none, :finish]}, states)

      assert context.tick_count == 2
    end
  end

  describe "all the states" do
    test "work through each state" do
      fake_actions = Enum.map(GameCommander.actions, fn {name, _} ->
        {name, &GameCommanderTest.fake_tick/1}
      end)

      context = GameCommander.start(:none, %{states: GameCommander.states}, fake_actions)

      assert context.tick_count == 8
    end
  end
end

