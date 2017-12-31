defmodule ShipTest do
  use ExUnit.Case

  describe "position" do
    test "construt defaults" do
      default_ship = %Ship{}

      assert default_ship.player == "Anonymous"
      assert default_ship.from   == %Position{x: 0, y: 0}
      assert default_ship.to     == %Position{x: 0, y: 0}
    end

    test "construct" do
      ship = %Ship{player: "Ed", from: %Position{x: 1, y: 1}, to: %Position{x: 5, y: 1}}

      assert ship.player == "Ed"
      assert ship.from.x == 1
      assert ship.from.y == 1
      assert ship.to.x   == 5
      assert ship.to.y   == 1
    end

    test "new raw position" do
      assert %Ship{from: %Position{x: 1, y: 2}, to: %Position{x: 3, y: 4}} == Ship.new("Anonymous", 1, 2, 3, 4)
    end

    test "new position map" do
      assert %Ship{from: %Position{x: 1, y: 2}, to: %Position{x: 3, y: 4}} == Ship.new("Anonymous", Position.new(1,2), Position.new(3,4))
    end
  end

  describe "strikes" do
    test "mark one piece of a ship as hit" do
      ship = Ship.new("Anonymous", 1, 2, 4, 2)
        |> Ship.strike(1, 2)

      assert %Ship{from: %Position{x: 1, y: 2}, to: %Position{x: 4, y: 2}, strikes: [%Position{x: 1, y: 2}]} == ship
    end

    test "many strikes" do
      ship = Ship.new("Anonymous", 1, 2, 4, 2)
        |> Ship.strike(1, 2)
        |> Ship.strike(2, 2)
        |> Ship.strike(3, 2)

      assert %Ship{from: %Position{x: 1, y: 2}, to: %Position{x: 4, y: 2}, strikes: [
        %Position{x: 1, y: 2}, %Position{x: 2, y: 2}, %Position{x: 3, y: 2}]} == ship
    end

    test "many strikes in the same location" do
      ship = Ship.new("Anonymous", 1, 2, 4, 2)
        |> Ship.strike(1, 2)
        |> Ship.strike(1, 2)
        |> Ship.strike(1, 2)

      assert %Ship{from: %Position{x: 1, y: 2}, to: %Position{x: 4, y: 2}, strikes: [
        %Position{x: 1, y: 2}]} == ship
    end

    test "missed the ship" do
       ship = Ship.new("Anonymous", 1, 2, 4, 2)
        |> Ship.strike(10, 20)

      assert %Ship{from: %Position{x: 1, y: 2}, to: %Position{x: 4, y: 2}, strikes: []} == ship
    end

    test "strike in constructor" do
      assert Ship.new("struck", 1, 1, 1, 2, [Position.new(1, 1)])
    end
  end

  describe "was struck" do
    test "hit" do
      ship = Ship.new("struck", 1, 1, 1, 2, [Position.new(1, 1)])

      assert Ship.struck?(ship, Position.new(1, 1))
    end

    test "missed" do
      ship = Ship.new("struck", 1, 1, 1, 2, [Position.new(1, 1)])

      refute Ship.struck?(ship, Position.new(1, 2))
    end
  end

  describe "question" do
    test "a strike" do
      ship = Ship.new("Anonymous", 1, 1, 1, 2)

      assert Ship.at?(ship, Position.new(1, 1))
      refute Ship.at?(ship, Position.new(10, 10))
    end
  end
end

