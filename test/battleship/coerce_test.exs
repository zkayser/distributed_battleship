defmodule CoerceTest do
  use ExUnit.Case

  describe "to_string" do
    test "from" do
      assert {:ok, "string"} == Coerce.string(:string)
      assert {:ok, "string"} == Coerce.string('string')
      assert {:ok, "string"} == Coerce.string("string")
    end

    test "fail" do
      assert {:error, "can not make it a string"} == Coerce.string(1)
      assert {:error, "can not make it a string"} == Coerce.string(nil)
      assert {:error, "can not make it a string"} == Coerce.string(%{not: "a string"})
    end
  end

end
