defmodule ContextTest do
  use ExUnit.Case

  test "construct default" do
    context = %Context{}
    
    assert context.tick_count == 0
    assert context.tick_rate_ms == 1000
    assert context.node_self == Node.self()
    assert context.node_cookie == Node.get_cookie()
  end

  test "new" do
    assert Context.new() == %{tick_count: 0, tick_rate_ms: 1000, node_self: Node.self(), node_cookie: Node.get_cookie()}
  end
  
end

