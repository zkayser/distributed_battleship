defmodule OceanTest do
  use ExUnit.Case

  setup() do
    pid = Ocean.start()

    on_exit(fn -> Ocean.stop(pid) end)

    [pid: pid]
  end

  describe "management" do

    test "stop the service" do
      {:ok, "Stopped"} = Ocean.stop()
    end
  end

  describe "ships" do
    test "add a ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, response} = Ocean.add_ship(context.pid, "Ed", 0, 0, 0, 10)

      assert response == "Added"

      {:ok, ships} = Ocean.ships(context.pid)
      assert {"Ed", 0, 0, 0, 10} in ships
    end

    test "add more than one ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 2)
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Jim",  1, 0, 0, 4)

      {:ok, ships} = Ocean.ships(context.pid)
      assert {"Fred", 0, 0, 0, 2} in ships
      assert {"Jim", 1, 0, 0, 4} in ships
    end

    test "ship that is off the ocean", context do
      {:ok, ocean_size} = Ocean.size(context.pid, %{"player1" => true, "player2" => true})

      data = [
        {0,0,0,ocean_size},
        {0,0,ocean_size,0},
        {0,ocean_size,0,0},
        {ocean_size,0,0,0},
        {0,0,0,-1},
        {0,0,-1,0},
        {0,-1,0,0},
        {-1,0,0,0},
      ]

      Enum.each(data, fn {from_lat, from_long, to_lat, to_long} ->
        result = Ocean.add_ship(context.pid, "Ahab", from_lat, from_long, to_lat, to_long)
        assert {:error, "off the ocean"} == result, "Position shouldn't work: #{from_lat}x#{from_long}_#{to_lat}x#{to_long}"
      end)
    end
  end

  describe "ocean size" do
    test "set ocean size", context do
      assert {:ok, 20} == Ocean.size(context.pid, %{"player1" => true, "player2" => true})
    end

    test "set and retrieve the size", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})

      assert {:ok, 20} == Ocean.size(context.pid)
    end

    test "we dont know the ocean size yet", context do
      {:error, "how big the ocean blue"} = Ocean.add_ship(context.pid, "Ahab", 0, 0, 0, 2)
    end
  end
 
end

