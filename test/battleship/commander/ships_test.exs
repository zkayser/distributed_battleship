defmodule ShipsTest do
  use ExUnit.Case

  test "strike" do
    ships = [
      Ship.new("strike", 1, 1, 1, 2),
      Ship.new("strike", 2, 2, 2, 3)
    ]

    assert Ship.new("strike", 1, 1, 1, 2, [Position.new(1, 2)]) in Ships.strike(ships, Position.new(1, 2))
    assert Ship.new("strike", 1, 1, 1, 2)                       in Ships.strike(ships, Position.new(10, 20))
  end

  test "is a ship struck" do
    ships = [
      Ship.new("strike", 1, 1, 1, 2),
      Ship.new("strike", 2, 2, 2, 3)
    ]

    assert Ships.at?(ships, Position.new(1,1))
    refute Ships.at?(ships, Position.new(10,10))
  end
end

