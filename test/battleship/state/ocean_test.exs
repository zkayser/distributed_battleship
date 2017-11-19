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
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Jim",  1, 0, 1, 4)

      {:ok, ships} = Ocean.ships(context.pid)
      assert {"Fred", 0, 0, 0, 2} in ships
      assert {"Jim", 1, 0, 1, 4} in ships
    end

    @tag :skip
    test "must only create horizontal or vertical ships" do

    end

    test "ship can not be off the ocean", context do
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

  describe "no diagonal ships" do
    @tag :skip
    test "from top left to bottom right" do
    end
    @tag :skip
    test "from bottom left to top right" do
    end
    @tag :skip
    test "from top right to bottom left" do
    end
    @tag :skip
    test "from bottom right to top left" do
    end
  end

  describe "ships must be longer then one ship part" do
    test "short ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:error, "ships must be longer then 1 part"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 0)
    end
  end

  describe "ship limit for players" do
    @tag :skip
    test "add too many ships", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 9)
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 1, 0, 1, 9)
      {:error, "ship limit exceeded: 21 > 20"} = Ocean.add_ship(context.pid, "Fred", 9, 0, 9, 0)
    end
  end

  describe "ships can not sit on other ships - horizontal to horizontal" do
    @tag :skip
    test "can not touch the bow of another ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 9)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 9)
    end

    @tag :skip
    test "can not touch the stern of another ship" do
    end
  end

  describe "ships can not sit on other ships - vertical to vertical" do
    @tag :skip
    test "can not touch the bow of another ship" do
    end
    @tag :skip
    test "can not touch the stern of another ship" do
    end
  end

  describe "ships can not sit on other ships - horizontal to vertical" do
    @tag :skip
    test "ships can not cross in the middle" do
    end
    @tag :skip
    test "can not touch the bow of another ship" do
    end
    @tag :skip
    test "can not touch the stern of another ship" do
    end
  end

end

