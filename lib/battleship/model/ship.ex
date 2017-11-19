defmodule Ship do
  defstruct player: "Anonymous", from: %Position{}, to: %Position{}

  def new(player, from_x, from_y, to_x, to_y) do
    %Ship{player: player, from: Position.new(from_x, from_y), to: Position.new(to_x, to_y) }
  end
end
