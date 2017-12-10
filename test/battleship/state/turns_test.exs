defmodule TurnsTest do
  use ExUnit.Case

  setup do
    pid = Turns.start()

    on_exit(fn -> Turns.stop(pid) end)

    %{pid: pid}
  end

  describe "control" do

    test "start turns", context do
      assert context.pid
    end

    test "stop turns", context do
      assert Turns.stop(context.pid)
    end
  end

  describe "take turn" do
    test "turn", context do
      result = Turns.take(context.pid, "Ed", %Position{x: 5, y: 10})

      assert result == {:ok}
    end
  end

  describe "process" do
    test "get turns", context do
      result= Turns.get(context.pid)

      assert result == []
    end
    
  end

end

