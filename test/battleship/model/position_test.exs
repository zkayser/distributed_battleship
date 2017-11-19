defmodule PositionTest do
  use ExUnit.Case

  test "construct default" do
    assert %Position{} == %Position{x: 0, y: 0}
  end

  test "construct" do
    position = %Position{x: 1, y: 2}

    assert position.x == 1
    assert position.y == 2
  end

  test "new" do
    assert %Position{x: 1, y: 2} == Position.new(1, 2)
  end
  
  
end

