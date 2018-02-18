defmodule PlayersTest do
  use ExUnit.Case

  setup() do
    pid = Players.start()

    on_exit(fn -> Players.stop(pid) end)

    [pid: pid]
  end

  describe "management" do

    test "service is registered" do
      refute :undefined == :global.whereis_name(:players)
    end

    test "stop the service" do
      Players.stop()
    end
  end

  describe "player count" do

    test "get player count", context do
      assert {:ok, 0} == Players.player_count(context.pid)
    end
  end

  describe "registering" do

    test "register player", context do
      assert {:ok, "Now there are 1 players"} == Players.register(context.pid, "Ed")

      assert {:ok, %{"Ed" => self()}} == Players.registered_players(context.pid)
    end

    test "register two player", context do
      assert {:ok, "Now there are 1 players"} == Players.register(context.pid, "Ed")
      assert {:ok, "Now there are 2 players"} == Players.register(context.pid, "Jim")

      assert {:ok, %{"Ed" => self(), "Jim" => self()}} == Players.registered_players(context.pid)
    end

    test "registered players when there are none", context do
      assert {:ok, %{}} == Players.registered_players(context.pid)
    end
  end

  describe "deactivation" do

    test "stop registering players", context do
      assert {:ok, "Now there are 1 players"} == Players.register(context.pid, "Ed")

      {:ok, players} = Players.stop_registering(context.pid)

      assert %{"Ed" => self()} == players
      assert {:error, "can not register anymore"} == Players.register(context.pid, "Late player")
    end
  end
  
  describe "player name type" do
    test "must be a string", context do
      assert {:ok, "Now there are 1 players"} == Players.register(context.pid, "Ed1")
      assert {:ok, "Now there are 2 players"} == Players.register(context.pid, 'Ed2')
      assert {:ok, "Now there are 3 players"} == Players.register(context.pid, :Ed3)

      {:ok, players} = Players.registered_players(context.pid)

      player_names = Map.keys(players)
      assert "Ed1" == Enum.at(player_names, 0), "Should have been a string, #{inspect Enum.at(player_names, 0)}"
      assert "Ed2" == Enum.at(player_names, 1), "Should have been a string, #{inspect Enum.at(player_names, 1)}"
      assert "Ed3" == Enum.at(player_names, 2), "Should have been a string, #{inspect Enum.at(player_names, 2)}"
    end

    test "dont register something that can not be turned into a string", context do
      assert {:error, "Player name must be a string"} == Players.register(context.pid, %{sorry: "No a string"})
    end
  end
end

