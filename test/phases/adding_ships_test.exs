defmodule AddingShipsTest do
  use ExUnit.Case

  test "initialize context" do
    phase_context = AddingShips.tick(%{})

    assert phase_context.wait_max == 60
    assert phase_context.wait_start
  end

  test "second tick no timeout yet" do
    phase_context = %{}
      |> AddingShips.tick()
      |> AddingShips.tick()

    assert phase_context.new_phase == :adding_ships
  end

  test "force a timeout and switch to new phase" do
    phase_context = %{wait_max: 0}
      |> AddingShips.tick()
      |> AddingShips.tick()

    assert phase_context.new_phase == :taking_turns
  end
end

