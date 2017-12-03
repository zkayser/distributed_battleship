defmodule PhaseTest do
  use ExUnit.Case

  setup() do
    pid = Trigger.start()

    on_exit(fn -> Trigger.stop(pid) end)

    [pid: pid]
  end

  describe "does the phase change" do
    test "no change in phase", context do
      state = Phase.change?(context.pid, %{changed: false}, fn state -> 
        Map.merge(state, %{changed: true})
      end)

      refute state.changed
    end

    test " change in phase", context do
      Phase.change(context.pid)

      state = Phase.change?(context.pid, %{}, fn state -> 
        Map.merge(state, %{changed: true})
      end)

      assert state.changed
    end
  end
end

