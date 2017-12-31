defmodule ShipsTest do
  use ExUnit.Case

  test "strike" do
    ships = [
      Ship.new("ship1", 1, 1, 1, 2),
      Ship.new("ship2", 2, 2, 2, 3)
    ]

    assert Ship.new("ship1", 1, 1, 1, 2, [Position.new(1, 2)]) in Ships.strike(ships, Position.new(1, 2))
    assert Ship.new("ship1", 1, 1, 1, 2)                       in Ships.strike(ships, Position.new(10, 20))
    assert Ship.new("ship2", 2, 2, 2, 3)                       in Ships.strike(ships, Position.new(10, 20))
  end

  test "is a ship struck" do
    ships = [
      Ship.new("ship1", 1, 1, 1, 2),
      Ship.new("ship2", 2, 2, 2, 3)
    ]

    assert Ships.at?(ships, Position.new(1,1))
    refute Ships.at?(ships, Position.new(10,10))
  end

  test "a strike is only tracked once" do
    ships = [
      Ship.new("ship1", 1, 1, 1, 2),
      Ship.new("ship2", 2, 2, 2, 3)
    ]
    |> Ships.strike(Position.new(1, 2))
    |> Ships.strike(Position.new(1, 2))

    assert Ship.new("ship1", 1, 1, 1, 2, [Position.new(1, 2)]) in ships
  end
end

