defmodule OceanTest do
  use ExUnit.Case

  setup() do
    pid = Ocean.start()

    on_exit(fn -> Ocean.stop() end)

    [pid: pid]
  end

  describe "management" do

    test "stop the service" do
      {:ok, "Stopped"} = Ocean.stop()
    end
  end

  describe "ocean active?" do

    test "can not get the ships until the ocean is active", context do
      assert {:error, "no ocean yet"} == Ocean.ships(context.pid)
    end

    test "can not get size until the ocean is active", context do
      assert {:error, "no ocean yet"} == Ocean.size(context.pid)
    end

    test "can not add a ship until the ocean is active", context do
      assert {:error, "no ocean yet"} == Ocean.add_ship(context.pid, "Ed", 0, 0, 0, 10)
    end

    test "can not strike a ship until the ocean is active", context do
      assert {:error, "no ocean yet"} == Ocean.strike(context.pid, %{x: 3, y: 3})
    end

    test "can not get the strikes until the ocean is active.", context do
      assert {:error, "no ocean yet"} == Ocean.strikes(context.pid)
    end

    test "when the ocean is active all the finctios work", context do
      assert {:error, "no ocean yet"} == Ocean.ships(context.pid)

      assert {:ok, 10, 8} == Ocean.size(context.pid, %{"player1" => true})

      assert {:ok, 10, 8}    == Ocean.size(context.pid)
      assert {:ok, []}       == Ocean.ships(context.pid)
      assert {:ok, "Added"}  == Ocean.add_ship(context.pid, "Ed", 0, 0, 0, 1)
      assert false           == Ocean.strike(context.pid, %{x: 3, y: 3})
      assert %{"Ed" => 0}    == Ocean.strikes(context.pid)
    end
  end

  describe "ocean size and max ships" do
    test "set ocean size to a rounded integer", context do
      assert {:ok, 10, 8} == Ocean.size(context.pid, %{"player1" => true})
    end

    test "set ocean size", context do
      assert {:ok, 20, 15} == Ocean.size(context.pid, %{"player1" => true, "player2" => true})
    end

    test "set and retrieve the size", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})

      assert {:ok, 20, 15} == Ocean.size(context.pid)
    end
  end

  describe "ships" do
    test "add a ship using internal struct", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, response} = Ocean.add_ship(context.pid, "Ed", 0, 0, 0, 10)

      assert response == "Added"

      {:ok, ships} = Ocean.ships(context.pid)
      assert Ship.new("Ed", 0, 0, 0, 10) in ships
    end

    test "add a ship with raw message", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      Ocean.add_ship(context.pid, "Ed", 0, 0, 0, 10)

      response = GenServer.call(context.pid, {:add_ship, %{ player: "Buster", from: %{ from_x: 1, from_y: 10 }, to: %{ to_x: 10, to_y: 10 } } })

      assert response == {:ok, "Added"}
    end

    test "add more than one ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 2)
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Jim",  1, 0, 1, 4)

      {:ok, ships} = Ocean.ships(context.pid)
      assert Ship.new("Fred", 0, 0, 0, 2) in ships
      assert Ship.new("Jim", 1, 0, 1, 4)  in ships
    end

    test "ship can not be off the ocean", context do
      {:ok, ocean_size, _} = Ocean.size(context.pid, %{"player1" => true, "player2" => true})

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

      Enum.each(data, fn {from_x, from_y, to_x, to_y} ->
        result = Ocean.add_ship(context.pid, "Ahab", from_x, from_y, to_x, to_y)
        assert {:error, "off the ocean: should be within 0x0 and #{ocean_size - 1}x#{ocean_size - 1}"} == result
      end)
    end

    test "the position of the ship must be numeric", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})

      data = [
        {"0",0,0,0},
        {0,"0",0,0},
        {0,0,"0",0},
        {0,0,0,"0"}
      ]

      # Raw message format
      Enum.each(data, fn {from_x, from_y, to_x, to_y} ->
        result = GenServer.call(context.pid, {:add_ship, %{ player: "BadShip", from: %{ from_x: from_x, from_y: from_y }, to: %{ to_x: to_x, to_y: to_y } } })
        assert result == {:error, "ship position must be numeric"}
      end)

      # Ship struct
      Enum.each(data, fn {from_x, from_y, to_x, to_y} ->
        result = Ocean.add_ship(context.pid, "BadShip", from_x, from_y, to_x, to_y)
        assert result == {:error, "ship position must be numeric"}
      end)
    end

  end

  describe "no diagonal ships" do
    test "from top left to bottom right", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:error, "ship must be horizontal or vertical"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 1, 1)
    end

    test "from bottom left to top right", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:error, "ship must be horizontal or vertical"} = Ocean.add_ship(context.pid, "Fred", 1, 0, 0, 1)
    end

    test "from top right to bottom left", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:error, "ship must be horizontal or vertical"} = Ocean.add_ship(context.pid, "Fred", 0, 1, 1, 0)
    end

    test "from bottom right to top left", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:error, "ship must be horizontal or vertical"} = Ocean.add_ship(context.pid, "Fred", 1, 1, 0, 0)
    end

    test "some other angle", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:error, "ship must be horizontal or vertical"} = Ocean.add_ship(context.pid, "Fred", 5, 3, 2, 8)
    end
  end

  describe "ships must be longer then one ship part" do
    test "short ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:error, "ships must be longer then 1 part"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 0)
    end
  end

  describe "ship limit for players" do
    test "add too many ships", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 6) # 7 parts
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 1, 0, 1, 6) # 7 parts

      {:error, "ship limit exceeded: you have 14 and are adding 2 ship parts. Max is 15"} =
          Ocean.add_ship(context.pid, "Fred", 9, 0, 9, 1) # 2 parts
    end
  end

  describe "ships can not sit on other ships - horizontal to horizontal" do
    test "can not sit right on top", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 5)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 5)
    end

    test "can not touch the bow of another ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 3, 0, 5)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 0, 3)
    end

    test "can not touch the stern of another ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 0, 3, 0, 5)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 0, 5, 0, 6)
    end
  end

  describe "ships can not sit on other ships - vertical to vertical" do
    test "can not sit on top of each other", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 0, 5, 0)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 3, 0, 5, 0)
    end

    test "can not touch the bow of another ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 0, 5, 0)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 5, 0, 6, 0)
    end

    test "can not touch the stern of another ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 0, 5, 0)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 0, 0, 3, 0)
    end
  end

  describe "ships can not sit on other ships - horizontal to vertical" do
    test "ships can not cross in the middle", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 3, 5, 3)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 4, 2, 4, 4)
    end

    test "can not touch the bow of another ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 3, 5, 3)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 3, 3, 3, 5)
    end
    
    test "can not touch the stern of another ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 3, 5, 3)
      {:error, "there is another ship here"} = Ocean.add_ship(context.pid, "Fred", 5, 3, 5, 5)
    end
  end

  describe "combat hits" do
    test "can a bomb hit a ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 3, 5, 3)

      assert true == Ocean.strike(context.pid, %{x: 3, y: 3})
    end

    test "can a bomb miss a ship", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 3, 5, 3)

      assert false == Ocean.strike(context.pid, %{x: 3, y: 4})
    end

    test "can a bomb hit one of many ships", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 3, 3, 5, 3)
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 6, 5, 6, 8)
      {:ok, "Added"} = Ocean.add_ship(context.pid, "Fred", 2, 7, 5, 7)

      assert true == Ocean.strike(context.pid, %{x: 4, y: 3})
      assert true == Ocean.strike(context.pid, %{x: 5, y: 3})

      assert true == Ocean.strike(context.pid, %{x: 6, y: 5})
      assert true == Ocean.strike(context.pid, %{x: 6, y: 6})
      assert true == Ocean.strike(context.pid, %{x: 6, y: 7})
      assert true == Ocean.strike(context.pid, %{x: 6, y: 8})

      assert true == Ocean.strike(context.pid, %{x: 2, y: 7})
      assert true == Ocean.strike(context.pid, %{x: 3, y: 7})
      assert true == Ocean.strike(context.pid, %{x: 4, y: 7})
      assert true == Ocean.strike(context.pid, %{x: 4, y: 7})

      # Lets miss a few in the same ocean
      assert false == Ocean.strike(context.pid, %{x: 2, y: 8})
      assert false == Ocean.strike(context.pid, %{x: 2, y: 6})
      assert false == Ocean.strike(context.pid, %{x: 3, y: 8})
      assert false == Ocean.strike(context.pid, %{x: 3, y: 6})
      assert false == Ocean.strike(context.pid, %{x: 4, y: 8})
      assert false == Ocean.strike(context.pid, %{x: 4, y: 6})
    end
  end

  describe "how many strikes" do

    test "who blewup who - one strike", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "player1", 3, 3, 5, 3)

      assert true == Ocean.strike(context.pid, %{x: 4, y: 3})

      assert %{"player1" => 1} ==  Ocean.strikes(context.pid) 
    end

    test "who blewup who, 2 strikes", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "player1", 3, 3, 5, 3)

      assert true == Ocean.strike(context.pid, %{x: 4, y: 3})
      assert true == Ocean.strike(context.pid, %{x: 5, y: 3})

      assert %{"player1" => 2} ==  Ocean.strikes(context.pid) 
    end

    test "two strikes in same poisition tracked as one strike", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "player1", 3, 3, 5, 3)

      assert true == Ocean.strike(context.pid, %{x: 4, y: 3})
      assert true == Ocean.strike(context.pid, %{x: 4, y: 3})

      assert %{"player1" => 1} ==  Ocean.strikes(context.pid) 
    end
  end

  describe "active players" do
    test "number when only there are no ships", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})

      assert 0 == Ocean.number_active_players(context.pid)
    end

    @tag :skip
    test "number when only one player has ships", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "player1", 3, 3, 5, 3)

      assert 1 == Ocean.number_active_players(context.pid)
    end

    @tag :skip
    test "number when both players have ships", context do
      Ocean.size(context.pid, %{"player1" => true, "player2" => true})
      {:ok, "Added"} = Ocean.add_ship(context.pid, "player1", 3, 3, 5, 3)
      {:ok, "Added"} = Ocean.add_ship(context.pid, "player2", 3, 4, 5, 4)

      assert 2 == Ocean.number_active_players(context.pid)
    end
  end
end

