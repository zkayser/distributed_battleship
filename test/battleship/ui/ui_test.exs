defmodule UiTest do
  use ExUnit.Case

  test "display something" do
    data = %{
      ships: [
        Ship.new("Foo", Position.new(3, 1), Position.new(5, 1)),
        Ship.new("Foo", Position.new(3, 2), Position.new(5, 2), [Position.new(3,2)]),
        Ship.new("Bar", Position.new(3, 3), Position.new(5, 3)),
        Ship.new("Bar", Position.new(3, 4), Position.new(5, 4), [Position.new(3,4), Position.new(4,4)]),
        Ship.new("Zap", Position.new(3, 5), Position.new(5, 5)),
        Ship.new("Zap", Position.new(3, 6), Position.new(5, 6), [Position.new(3,6), Position.new(4,6), Position.new(5,6)]),
      ]
    }

    output = Ui.render(:text, 10, data)

    assert output == "/ 0123456789\n"
    <> "0 ~~~~~~~~~~\n"
    <> "1 ~~~FFF~~~~\n"
    <> "2 ~~~XFF~~~~\n"
    <> "3 ~~~BBB~~~~\n"
    <> "4 ~~~XXB~~~~\n"
    <> "5 ~~~ZZZ~~~~\n"
    <> "6 ~~~XXX~~~~\n"
    <> "7 ~~~~~~~~~~\n"
    <> "8 ~~~~~~~~~~\n"
    <> "9 ~~~~~~~~~~\n"
    <> "\n"
    <> "B: Bar\n"
    <> "F: Foo\n"
    <> "Z: Zap\n"
  end
end

