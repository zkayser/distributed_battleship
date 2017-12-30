defmodule TurnsTest do
  use ExUnit.Case

  setup do
    pid = Turns.start()

    on_exit(fn -> Turns.stop() end)

    %{pid: pid}
  end

  describe "control" do

    test "start turns", context do
      assert context.pid
    end

    test "stop turns", context do
      assert {:ok, "Stopped"} == Turns.stop(context.pid)
    end

    test "stop by name" do
      assert {:ok, "Stopped"} == Turns.stop()
    end
  end

  describe "take turn" do
    test "turn", context do
      assert {:ok} = Turns.take(context.pid, "Ed", %Position{x: 5, y: 10})
    end

    test "with raw parameters", context do
      assert {:ok} = Turns.take(context.pid, "Ed", %{x: 5, y: 10})
    end
  end

  describe "process" do
    test "get turns", context do
      result= Turns.get(context.pid)

      assert result == []
    end

    test "take a turn and get it", context do
      {:ok} = Turns.take(context.pid, "Ed", %Position{x: 5, y: 10})

      result = Turns.get(context.pid)

      assert result == [{"Ed", %Position{x: 5, y: 10}}]
    end
    
    test "take many turns and get them", context do
      {:ok} = Turns.take(context.pid, "Ed",   %Position{x: 1, y: 11})
      {:ok} = Turns.take(context.pid, "Jim",  %Position{x: 2, y: 12})
      {:ok} = Turns.take(context.pid, "Fred", %Position{x: 3, y: 13})
      {:ok} = Turns.take(context.pid, "Bob",  %Position{x: 4, y: 14})

      result = Turns.get(context.pid)

      assert result == [
        {"Ed",   %Position{x: 1, y: 11}},
        {"Jim",  %Position{x: 2, y: 12}},
        {"Fred", %Position{x: 3, y: 13}},
        {"Bob",  %Position{x: 4, y: 14}},
      ]
    end

    test "ensure that all turns are returned at once and the next are none", context do
      {:ok} = Turns.take(context.pid, "Ed",   %Position{x: 1, y: 11})

      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.pid)

      assert [] == Turns.get(context.pid)
      assert [] == Turns.get(context.pid)
      assert [] == Turns.get(context.pid)
      assert [] == Turns.get(context.pid)
    end

    test "repeat the turn and get sequence", context do
      Turns.take(context.pid, "Ed",   %Position{x: 1, y: 11})
      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.pid)

      Turns.take(context.pid, "Ed",   %Position{x: 1, y: 11})
      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.pid)

      Turns.take(context.pid, "Ed",   %Position{x: 1, y: 11})
      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.pid)

      Turns.take(context.pid, "Ed",   %Position{x: 1, y: 11})
      [{"Ed", %Position{x: 1, y: 11}}] = Turns.get(context.pid)
    end
  end

  describe "wrong types" do
    test "string x coord", context do
      result = Turns.take(context.pid, "Ed",   %Position{x: "1", y: 11})

      assert result == {:error, "position must be numeric"}
    end
    test "string y coord", context do
      result = Turns.take(context.pid, "Ed",   %Position{x: 1, y: "11"})

      assert result == {:error, "position must be numeric"}
    end
  end
end

