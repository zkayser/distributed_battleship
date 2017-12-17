defmodule Ships do
  def strike?(ships, bomb) do
    Enum.any?(ships, fn ship -> Ship.strike?(ship, bomb) end)
  end

  def strike(ships, bomb) do
    Enum.reduce(ships, [], fn ship, acc -> 
      acc ++ [Ship.strike(ship, bomb.x, bomb.y)] 
    end)
  end
end
