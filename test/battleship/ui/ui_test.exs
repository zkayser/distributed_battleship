defmodule UiTest do
  use ExUnit.Case

  test "display something" do
    data = %{
      ships: 
      strikes: %{"Foo" => :something}
    }

    Ui.render(:text, data)
  end
end

