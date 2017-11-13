defmodule CollisionTest do
  use ExUnit.Case

  describe "orientation" do
    test "clockwise" do
      assert :clockwise == Collision.orientation({1,1},{1,2},{2,1})
      assert :clockwise == Collision.orientation({1,1},{3,2},{2,1})
      assert :clockwise == Collision.orientation({10,20},{3,12},{3,30})
    end

    test "counter clockwise" do
      assert :counterclockwise == Collision.orientation({2,1},{2,2},{1,1})
    end
  
    test "colinear" do
      assert :colinear == Collision.orientation({1,1},{1,2},{1,3})
    end
  end
end

