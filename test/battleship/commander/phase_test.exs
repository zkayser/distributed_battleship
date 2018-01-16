defmodule PhaseTest do
  use ExUnit.Case

  setup() do
    pid = Trigger.start()

    on_exit(fn -> Trigger.stop(pid) end)

    [pid: pid]
  end

  describe "does the phase change" do
    test "no change in phase", context do
      state = Phase.change?(context.pid, %{}, :new_phase)

      refute state[:new_phase] == :new_phase
    end

    test "change in phase", context do
      Phase.change(context.pid)

      state = Phase.change?(context.pid, %{}, :new_phase)

      assert state.new_phase == :new_phase
    end

    test "callback on change", context do
      Phase.change(context.pid)

      phase_context = Phase.change?(context.pid, %{}, :new_phase, fn phase_context ->
        Map.merge(phase_context, %{yup_is_was_notified: true})
      end)

      assert phase_context.yup_is_was_notified
    end
  end

  describe "change without trigger" do
    test "make local change to context" do
      state = Phase.change(%{}, :new_phase)

      assert state.new_phase == :new_phase
    end

    test "call back when changed" do
      state = Phase.change(%{}, :new_phase, fn phase_context ->
        Map.merge(phase_context, %{yup_is_was_notified: true})
      end)

      assert state.new_phase == :new_phase
      assert state.yup_is_was_notified
    end
  end
end

