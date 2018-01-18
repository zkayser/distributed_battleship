defmodule AddingShipsTest do
  use ExUnit.Case

  setup() do
    trigger_pid = Trigger.start()
    turns_pid = Turns.start()

    on_exit(fn -> 
      Trigger.stop()
      Turns.stop()
    end)

    [trigger_pid: trigger_pid, turns_pid: turns_pid]
  end

  test "initialize context", context do
    phase_context = AddingShips.tick(%{service: %{trigger_pid: context.trigger_pid, turns_pid: context.turns_pid}})

    refute Map.has_key?(phase_context, :new_phase)
  end

  test "second tick no phase change", context do
    phase_context = %{service: %{trigger_pid: context.trigger_pid, turns_pid: context.turns_pid}}
      |> AddingShips.tick()
      |> AddingShips.tick()

    refute Map.has_key?(phase_context, :new_phase)
  end

  test "triger a phase chnage and switch to new phase", context do
    Trigger.pull(context.trigger_pid)

    phase_context = %{service: %{trigger_pid: context.trigger_pid, turns_pid: context.turns_pid}}
      |> AddingShips.tick()

    assert phase_context.new_phase == :taking_turns
    assert Turns.is_active(context.turns_pid)
  end
end

