defmodule TakingTurnsTest do
  use ExUnit.Case

  describe "throw bomb" do
    test "miss" do
      assert TakingTurns.tick(%{})
    end
  end
end

