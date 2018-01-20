defmodule FinishTest do
  use ExUnit.Case

  setup() do
    players_pid = Players.start()
    ocean_pid = Ocean.start()

    Players.register(players_pid, "Foo")
    Players.register(players_pid, "Bar")

    Ocean.size(ocean_pid, %{"player1" => true, "player2" => true})
    {:ok, "Added"} = Ocean.add_ship(ocean_pid, "player1", 0, 0, 0, 2)
    {:ok, "Added"} = Ocean.add_ship(ocean_pid, "player2", 1, 0, 1, 4)

    on_exit(fn -> 
      Players.stop()
      Ocean.stop()
    end)

    [
      ocean_pid: ocean_pid,
      phase_context: %{service: %{players_pid: players_pid, ocean_pid: ocean_pid}}
    ]
  end

  describe "initialize" do
    test "setup the initial phase context", context do
      Finish.tick(context.phase_context)
    end
  end

  describe "game over" do
    test "Notify everyone of the winner", context do
      Finish.tick(context.phase_context)

      assert_receive {:game_over, winner: "player1"}
      assert_receive {:game_over, winner: "player1"}
    end
  end

  describe "notifications" do
    test "just once", context do
      phase_context = Finish.tick(context.phase_context)

      assert_receive {:game_over, winner: "player1"}
      assert_receive {:game_over, winner: "player1"}

      Finish.tick(phase_context)

      refute_received {:game_over, winner: "player1"}
    end
    
  end
  
end

