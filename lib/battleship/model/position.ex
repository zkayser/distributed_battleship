defmodule Position do
  defstruct x: 0, y: 0

  def new(x, y) do
    %Position{x: x, y: y}
  end
end
