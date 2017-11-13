defmodule Collision do
  # http://www.geeksforgeeks.org/orientation-3-ordered-points/
  # 0,0 is top left.
  def orientation({point1_y, point1_x}, {point2_y, point2_x}, {point3_y, point3_x }) do

    value = (point2_y - point1_y) * (point3_x - point2_x) - (point2_x - point1_x) * (point3_y - point2_y)
    cond do
      value == 0 -> :colinear
      value < 0  -> :clockwise
      value > 0  -> :counterclockwise
    end
  end
end
