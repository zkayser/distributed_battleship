defmodule TakingTurnsTest do
  use ExUnit.Case
  
  import ExUnit.CaptureLog

  setup() do
    players_pid = Players.start()
    ocean_pid = Ocean.start()
    turns_pid = Turns.start()

    Players.register(players_pid, "Foo")
    Players.register(players_pid, "Bar")

    Turns.activate(turns_pid)

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

  def setup_ocean_size(context) do
    Ocean.size(context.ocean_pid, %{"player1" => true, "player2" => true})
    {:ok, "Added"} = Ocean.add_ship(context.ocean_pid, "Foo", 0, 0, 0, 2)
    {:ok, "Added"} = Ocean.add_ship(context.ocean_pid, "Bar", 1, 0, 1, 4)

    :ok
  end

  describe "initialize" do
    setup :setup_ocean_size

    test "setup the initial phase context", context do
      phase_context = TakingTurns.tick(context.phase_context)

      assert phase_context.turn_count == 0
      assert Map.size(phase_context.registered_players) > 0
    end
  end

  describe "take turns before ocean active" do
    test "should not take a turn", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 5, y: 10})

      output = capture_log fn ->
        phase_context = TakingTurns.tick(phase_context)

        # no turns are taken
        assert phase_context.turn_count == 0
      end

      assert output =~ "Foo is trying to take a turn before there is an ocean"
    end
  end

  describe "turn tracking" do
    setup :setup_ocean_size

    test "no turns", context do
      phase_context = context.phase_context
        |> TakingTurns.tick()
        |> TakingTurns.tick()

      assert phase_context.turn_count == 0
    end

    test "two turns", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 5, y: 10})
      {:ok} = Turns.take(context.turns_pid, "Bar", %{x: 5, y: 10})

      phase_context = TakingTurns.tick(phase_context)

      assert phase_context.turn_count == 2
    end
  end

  describe "apply turn to ocean" do
    setup :setup_ocean_size

    test "one miss", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 5, y: 10})
 
      phase_context = TakingTurns.tick(phase_context)

      assert {"Foo", %{x: 5, y: 10}, :miss} in phase_context.turn_results
    end
    
    test "one strike", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 0, y: 0})
 
      phase_context = TakingTurns.tick(phase_context)

      assert {"Foo", %{x: 0, y: 0}, :hit} in phase_context.turn_results
    end
  end

  describe "notify players of turn results" do
    setup :setup_ocean_size

    test "one player one turn", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 0, y: 0})
 
      TakingTurns.tick(phase_context)

      assert_receive {"Foo", %{x: 0, y: 0}, :hit}
    end

    test "one player two turns", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 0, y: 0})
      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 5, y: 10})
 
      TakingTurns.tick(phase_context)

      assert_receive {"Foo", %{x: 0, y: 0},  :hit}
      assert_receive {"Foo", %{x: 5, y: 10}, :miss}
    end

    test "two players two turns each", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 0, y: 0})
      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 5, y: 10})
      {:ok} = Turns.take(context.turns_pid, "Bar", %{x: 1, y: 0})
      {:ok} = Turns.take(context.turns_pid, "Bar", %{x: 5, y: 10})
 
      TakingTurns.tick(phase_context)

      assert_receive {"Foo", %{x: 0, y: 0},  :hit}      
      assert_receive {"Foo", %{x: 5, y: 10}, :miss}
      assert_receive {"Bar", %{x: 1, y: 0},  :hit}      
      assert_receive {"Bar", %{x: 5, y: 10}, :miss}
    end

    test "one player should learn about the other players strike", context do
      phase_context = TakingTurns.tick(context.phase_context)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 0, y: 0})
 
      TakingTurns.tick(phase_context)

      assert_receive {"Foo", %{x: 0, y: 0}, :hit}      
      assert_receive {"Foo", %{x: 0, y: 0}, :hit}
    end
  end

  describe "found a winner" do
    setup :setup_ocean_size

    test "change phase when one player left", context do
      phase_context = TakingTurns.tick(context.phase_context)
      refute Map.has_key?(phase_context, :new_phase)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 0, y: 0})
      phase_context = TakingTurns.tick(phase_context)
      assert Turns.is_active(context.turns_pid)

      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 0, y: 1})
      phase_context = TakingTurns.tick(phase_context)
      assert Turns.is_active(context.turns_pid)
      
      {:ok} = Turns.take(context.turns_pid, "Foo", %{x: 0, y: 2})
      phase_context = TakingTurns.tick(phase_context)

      refute Turns.is_active(context.turns_pid)
      assert :finish == phase_context.new_phase
    end
    
  end

  describe "players that disconnect" do
    setup :setup_ocean_size

    test "handle failed send to invalid pid", context do
      phase_context = TakingTurns.tick(context.phase_context)

      phase_context = Map.merge(phase_context, %{ registered_players: %{"Foo" => :erlang.list_to_pid('<0.999.0>')} })

      Turns.take(context.turns_pid, "Foo", %{x: 0, y: 0})

      TakingTurns.tick(phase_context)
    end
    
  end
end

