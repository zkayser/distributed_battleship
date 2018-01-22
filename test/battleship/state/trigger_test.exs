defmodule TriggerTest do
  use ExUnit.Case

  setup do
    pid = Trigger.start()

    on_exit(fn -> Trigger.stop(pid) end)

    [pid: pid]
  end

  describe "control" do

    test "stop turns", context do
      assert {:ok, "Stopped"} == Trigger.stop(context.pid)
    end

    test "stop by name" do
      assert {:ok, "Stopped"} == Trigger.stop()
    end
  end

  test "initialize", context do
    refute Trigger.pulled?(context.pid), "Shouldn't have pulled trigger yet"
  end

  test "pull the trigger", context do
    Trigger.pull(context.pid)

    assert Trigger.pulled?(context.pid), "Should have pulled trigger"
  end

  test "trigger is reset after it has been retrieved", context do
    Trigger.pull(context.pid)
    Trigger.pulled?(context.pid)

    refute Trigger.pulled?(context.pid), "Trigger should have been reset"
  end
end

