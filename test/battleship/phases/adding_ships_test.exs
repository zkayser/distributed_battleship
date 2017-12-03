defmodule AddingShipsTest do
  use ExUnit.Case

  setup() do
    trigger_pid = Trigger.start()

    on_exit(fn -> 
      Trigger.stop()
    end)

    [trigger_pid: trigger_pid]
  end


  test "initialize context", context do
    phase_context = AddingShips.tick(%{service: %{trigger_pid: context.trigger_pid}})

    refute Map.has_key?(phase_context, :new_phase)
  end

  test "second tick no timeout yet", context do
    phase_context = %{service: %{trigger_pid: context.trigger_pid}}
      |> AddingShips.tick()
      |> AddingShips.tick()

    refute Map.has_key?(phase_context, :new_phase)
  end

  test "force a timeout and switch to new phase", context do
    Trigger.pull(context.trigger_pid)

    phase_context = %{service: %{trigger_pid: context.trigger_pid}}
      |> AddingShips.tick()

    assert phase_context.new_phase == :taking_turns
  end
end

