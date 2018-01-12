defmodule PlayersTest do
  use ExUnit.Case

  setup() do
    pid = Players.start()

    on_exit(fn -> Players.stop(pid) end)

    [pid: pid]
  end

  test "stop the service" do
    Players.stop()
  end

  test "get player count", context do
    assert {:ok, 0} == Players.player_count(context.pid)
  end

  test "register player", context do
    assert {:ok, "Now there are 1 players"} == Players.register(context.pid, "Ed")

    assert {:ok, %{"Ed" => self()}} == Players.registered_players(context.pid)
  end

  test "registered players when there are none", context do
    assert {:ok, %{}} == Players.registered_players(context.pid)
  end

  test "service is registered" do
    refute :undefined == :global.whereis_name(:players)
  end

  test "stop registering players", context do
    assert {:ok, "Now there are 1 players"} == Players.register(context.pid, "Ed")

    {:ok, players} = Players.stop_registering(context.pid)

    assert %{"Ed" => self()} == players
    assert {:error, "can not register anymore"} == Players.register(context.pid, "Late player")
  end
  
  
end

