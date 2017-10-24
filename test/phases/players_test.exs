defmodule PlayersTest do
  use ExUnit.Case

  setup() do
    pid = Players.start()

    on_exit(fn -> Players.stop(pid) end)

    [pid: pid]
  end

  test "get player count", context do
    assert 0 == Players.player_count(context.pid)
  end

  test "service is registered" do
    refute :undefined == :global.whereis_name(:players)
  end
  
end

