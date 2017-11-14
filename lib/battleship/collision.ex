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

  # http://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
  def intersect(
        line1_point1 = {_, _}, 
        line1_point2 = {_, _},
        line2_point1 = {_, _}, 
        line2_point2 = {_, _}) do

    orientation_1_1 = orientation(line1_point1, line1_point2, line2_point1)
    orientation_1_2 = orientation(line1_point1, line1_point2, line2_point2)
    orientation_2_1 = orientation(line2_point1, line2_point2, line1_point1)
    orientation_2_2 = orientation(line2_point1, line2_point2, line1_point2)

    cond do
      # General Case
      orientation_1_1 != orientation_1_2 && orientation_2_1 != orientation_2_2 -> true

      # Special Cases
      orientation_1_1 == :colinear && on_line(line1_point1, line1_point2, line2_point1) -> true
      orientation_1_2 == :colinear && on_line(line1_point1, line1_point2, line2_point2) -> true
      orientation_2_1 == :colinear && on_line(line2_point1, line2_point2, line1_point1) -> true
      orientation_2_2 == :colinear && on_line(line2_point1, line2_point2, line1_point2) -> true
      true                                                                              -> false
    end
  end

  def on_line({line_point1_x, line_point1_y}, {line_point2_x, line_point2_y}, {point_x, point_y}) do
    point_x in min(line_point1_x, line_point2_x)..max(line_point1_x, line_point2_x)  &&
    point_y in min(line_point1_y, line_point2_y)..max(line_point1_y, line_point2_y)
  end

end
