defmodule ShipTest do
  use ExUnit.Case

  test "construt defaults" do
    default_ship = %Ship{}

    assert default_ship.player == "Anonymous"
    assert default_ship.from   == %Position{x: 0, y: 0}
    assert default_ship.to     == %Position{x: 0, y: 0}
  end

  test "construt" do
    ship = %Ship{player: "Ed", from: %Position{x: 1, y: 1}, to: %Position{x: 5, y: 1}}

    assert ship.player == "Ed"
    assert ship.from.x == 1
    assert ship.from.y == 1
    assert ship.to.x   == 5
    assert ship.to.y   == 1
  end

  test "new" do
    assert %Ship{from: %Position{x: 1, y: 2}, to: %Position{x: 3, y: 4}} == Ship.new("Anonymous", 1, 2, 3, 4)
  end
end

