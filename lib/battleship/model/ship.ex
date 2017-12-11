defmodule Ship do
  defstruct player: "Anonymous", from: %Position{}, to: %Position{}, strikes: []

  def new(player, from_x, from_y, to_x, to_y) do
    %Ship{player: player, from: Position.new(from_x, from_y), to: Position.new(to_x, to_y) }
  end

  def strike(ship, x, y) do
    strike_or_miss(Collision.intersect({ship.from.x, ship.from.y}, {ship.to.x, ship.to.y}, {x, y}, {x, y}), ship, x, y)
  end

  defp strike_or_miss(false, ship, _x, _y), do: ship
  defp strike_or_miss(true,  ship, x, y) do
    Map.merge(ship, %{strikes: ship.strikes ++ [%Position{x: x, y: y}]})
  end
end
