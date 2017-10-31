defmodule PlayersTest do
  use ExUnit.Case

  setup() do
    pid = Players.start()

    on_exit(fn -> Players.stop(pid) end)
  end

  test "get player count" do
    assert {:ok, 0} == Players.player_count()
  end

  test "register player" do
    assert {:ok, "Now there are 1 players"} == Players.register("Ed")

    assert {:ok, %{"Ed" => self()}} == Players.registered_players()
  end

  test "service is registered" do
    refute :undefined == :global.whereis_name(:players)
  end
  
end

