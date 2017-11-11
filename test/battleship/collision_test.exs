defmodule CollisionTest do
  use ExUnit.Case

  describe "orientation" do
    @tag :skip
    test "clockwise" do
      assert :clockwise == Collision.orientation({1,1},{1,2},{2,1})
    end

    @tag :skip
    test "counter clockwise" do
      assert :counterclockwise == Collision.orientation({2,1},{2,2},{1,1})
    end
  
    @tag :skip
    test "collinear" do
      assert :collinear == Collision.orientation({1,1},{1,2},{1,3})
    end
  end
end

