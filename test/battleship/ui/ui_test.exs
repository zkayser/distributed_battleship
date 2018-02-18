defmodule UiTest do
  use ExUnit.Case

  describe "private" do
    test "ui" do
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

      assert output == "/  0123456789\n"
      <> "00 ~~~~~~~~~~\n"
      <> "01 ~~~FFF~~~~\n"
      <> "02 ~~~XFF~~~~\n"
      <> "03 ~~~BBB~~~~\n"
      <> "04 ~~~XXB~~~~\n"
      <> "05 ~~~ZZZ~~~~\n"
      <> "06 ~~~XXX~~~~\n"
      <> "07 ~~~~~~~~~~\n"
      <> "08 ~~~~~~~~~~\n"
      <> "09 ~~~~~~~~~~\n"
      <> "\n"
      <> "B: Bar\n"
      <> "F: Foo\n"
      <> "Z: Zap\n"
    end
  end

  describe "public" do
    test "ui" do
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

      output = Ui.render(:text, 10, data, :public)

      assert output == "/  0123456789\n"
      <> "00 ~~~~~~~~~~\n"
      <> "01 ~~~~~~~~~~\n"
      <> "02 ~~~X~~~~~~\n"
      <> "03 ~~~~~~~~~~\n"
      <> "04 ~~~XX~~~~~\n"
      <> "05 ~~~~~~~~~~\n"
      <> "06 ~~~XXX~~~~\n"
      <> "07 ~~~~~~~~~~\n"
      <> "08 ~~~~~~~~~~\n"
      <> "09 ~~~~~~~~~~\n"
      <> "\n"
      <> "B: Bar\n"
      <> "F: Foo\n"
      <> "Z: Zap\n"
    end
  end
end

