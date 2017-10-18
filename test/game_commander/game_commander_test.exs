defmodule GameCommanderTest do
  use ExUnit.Case

  def fake_tick(context) do
    context
  end

  describe "tick" do
    test "trigger an action on a tick" do
      context = GameCommander.start(:none, %{none: &GameCommanderTest.fake_tick/1})

      assert context.tick_count == 1
    end
  end


end

