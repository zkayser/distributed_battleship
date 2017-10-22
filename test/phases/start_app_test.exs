defmodule StartAppTest do
  use ExUnit.Case

  test "transition to waiting_for_player phase" do
    context = StartApp.tick(%{})

    assert context.new_state == :waiting_for_players
    assert GameCommander.valid_phase?(context.new_state)
  end
end

