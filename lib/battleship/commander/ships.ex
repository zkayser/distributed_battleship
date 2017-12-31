defmodule Ships do
  def at?(ships, bomb) do
    Enum.any?(ships, fn ship -> Ship.at?(ship, bomb) end)
  end

  def strike(ships, bomb) do
    Enum.reduce(ships, [], fn ship, acc -> 
      acc ++ [Ship.strike(ship, bomb.x, bomb.y)] 
    end)
  end
end
