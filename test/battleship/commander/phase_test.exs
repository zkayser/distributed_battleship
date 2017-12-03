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
  end

  describe "change without trigger" do
    test "make local change to context" do
      state = Phase.change(%{}, :new_phase)

      assert state.new_phase == :new_phase
    end
    
  end
end

