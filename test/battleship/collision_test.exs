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

  describe "lines intersecting" do
    test "simple crosses" do
      assert Collision.intersect({1,1}, {10,10}, {10,1}, {1,10})
    end

    test "parallel horizontal" do
      refute Collision.intersect({1,1}, {1,10}, {10,1}, {10,10})
    end

    test "parallel vertical" do
      refute Collision.intersect({1,1}, {10,1}, {1,10}, {10,10})
    end
  end

  describe "on a horizontal line" do
    test "in middle" do
      assert Collision.on_line({1,1}, {1,10}, {1,5})
    end

    test "on one end" do
      assert Collision.on_line({1,1}, {1,10}, {1,10})
      assert Collision.on_line({1,1}, {1,10}, {1,1})
    end

    test "reversed points" do
      assert Collision.on_line({1,10}, {1,1}, {1,5})
    end

    test "above the line" do
      refute Collision.on_line({5,1}, {5,10}, {2,5})
    end

    test "below the line" do
      refute Collision.on_line({1,1}, {1,10}, {2,5})
    end
    
  end

  describe "on a vertical line" do
    test "in middle" do
      assert Collision.on_line({1,1}, {10,1}, {5,1})
    end

    test "on one end" do
      assert Collision.on_line({1,1}, {10,1}, {10,1})
      assert Collision.on_line({1,1}, {10,1}, {1,1})
    end

    test "reversed points" do
      assert Collision.on_line({10,1}, {1,1}, {5,1})
    end

    test "left the line" do
      refute Collision.on_line({1,5}, {10,5}, {5,2})
    end

    test "right the line" do
      refute Collision.on_line({1,1}, {10,1}, {5,2})
    end
    
  end
end

