defmodule TakingTurnsTest do
  use ExUnit.Case

  setup() do
    players_pid = Players.start()
    ocean_pid = Ocean.start()
    turns_pid = Turns.start()

    Players.register(players_pid, "Foo")
    Players.register(players_pid, "Bar")

    Ocean.size(ocean_pid, %{"player1" => true, "player2" => true})
    {:ok, "Added"} = Ocean.add_ship(ocean_pid, "Fred", 0, 0, 0, 2)
    {:ok, "Added"} = Ocean.add_ship(ocean_pid, "Jim",  1, 0, 1, 4)

    on_exit(fn -> 
      Players.stop()
      Ocean.stop()
      Turns.stop()
    end)

    [
      ocean_pid: ocean_pid, turns_pid: turns_pid,
      phase_context: %{service: %{players_pid: players_pid, ocean_pid: ocean_pid, turns_pid: turns_pid}}
    ]
  end

  describe "initialize" do
    test "setup the initial phase context", context do
      phase_context = TakingTurns.tick(context.phase_context)

      assert phase_context.turn_count == 0
      assert Map.size(phase_context.registered_players) > 0
    end
  end

  describe "turn tracking" do
    test "no turns", context do
      phase_context = context.phase_context
        |> TakingTurns.tick()
        |> TakingTurns.tick()

      assert phase_context.turn_count == 0
    end

    test "two turns", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Ed", %{x: 5, y: 10})
      {:ok} = Turns.take(context.turns_pid, "Jim", %{x: 5, y: 10})

      phase_context = TakingTurns.tick(phase_context)

      assert phase_context.turn_count == 2
    end
  end

  describe "apply turn to ocean" do
    test "one miss", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Ed", %{x: 5, y: 10})
 
      phase_context = TakingTurns.tick(phase_context)

      assert {"Ed", %{x: 5, y: 10}, :miss} in phase_context.turn_results
    end
    
    test "one strike", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Ed", %{x: 0, y: 0})
 
      phase_context = TakingTurns.tick(phase_context)

      assert {"Ed", %{x: 0, y: 0}, :hit} in phase_context.turn_results
    end
  end
end

