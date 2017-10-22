defmodule GameCommanderTest do
  use ExUnit.Case

  def fake_tick(context) do
    Map.merge(context, %{new_state: hd(context.test_states), test_states: tl(context.test_states)})
  end

  describe "tick" do
    test "trigger an action on a tick" do
      context = GameCommander.start(:none, %{test_states: [:finish]}, [none: &GameCommanderTest.fake_tick/1])

      assert context.tick_count == 1
    end

    test "run two ticks" do
      actions = [
        none: &GameCommanderTest.fake_tick/1,
        finish: &GameCommanderTest.fake_tick/1
      ]

      context = GameCommander.start(:none, %{test_states: [:none, :finish]}, actions)

      assert context.tick_count == 2
    end
  end

  describe "all the states" do
    test "work through each state" do
      actions = Enum.map(GameCommander.actions, fn {name, _} ->
        {name, &GameCommanderTest.fake_tick/1}
      end)

      context = GameCommander.start(:none, %{test_states: GameCommander.states}, actions)

      assert context.tick_count == 8
    end
  end

  test "should ensure that a phase name is spelled correctly" do
    refute GameCommander.valid_phase?(nil)
    refute GameCommander.valid_phase?("")
    refute GameCommander.valid_phase?(:invalid)

    Enum.each GameCommander.states(), fn state ->
      assert GameCommander.valid_phase?(state)
    end
  end
  
end

