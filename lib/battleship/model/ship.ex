defmodule Ship do
  defstruct player: "Anonymous", from: %Position{}, to: %Position{}, strikes: []

  def new(player, from_x, from_y, to_x, to_y, strikes \\ []) do
    %Ship{player: player, from: Position.new(from_x, from_y), to: Position.new(to_x, to_y), strikes: strikes}
  end

  def strike?(ship, position) do
    Collision.intersect(
      {ship.from.x, ship.from.y}, {ship.to.x, ship.to.y},
      {position.x, position.y}, {position.x, position.y})
  end

  def strike(ship, x, y) do
    strike?(ship, Position.new(x, y))
    |> strike_or_miss(ship, Position.new(x, y))
  end

  defp strike_or_miss(false, ship, _osition), do: ship
  defp strike_or_miss(true,  ship, position) do
    Map.merge(ship, %{strikes: ship.strikes ++ [position]})
  end
end
