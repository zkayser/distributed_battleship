defmodule StartAppTest do
  use ExUnit.Case

  test "transition to waiting_for_player phase" do
    phase_context = StartApp.tick(%{})

    assert phase_context.new_phase == :waiting_for_players
    assert GameCommander.valid_phase?(phase_context.new_phase)
  end
end

