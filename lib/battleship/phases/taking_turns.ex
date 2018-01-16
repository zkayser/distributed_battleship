defmodule TakingTurns do
  @moduledoc """
    Each player can, throw bombs at any time. Those turns are compiled and evaulated each tick.
  """

  require Logger
  
  def tick(phase_context = %{turn_count: turn_count, registered_players: registered_players, service: %{ocean_pid: ocean_pid, turns_pid: turns_pid}}) do
    turns = Turns.get(turns_pid)

    turn_results = take_turns([], ocean_pid, registered_players, turns)

    Map.merge(phase_context, %{turn_count: turn_count + length(turn_results), turn_results: turn_results})
  end

  def tick(phase_context = %{service: %{players_pid: players_pid}}) do
    {:ok, registered_players} = Players.registered_players(players_pid)

    Map.merge(phase_context, %{
      turn_count: 0,
      registered_players: registered_players
    })
  end

  defp take_turns(turn_results, _ocean_pid, _registered_players, []), do: turn_results
  defp take_turns(turn_results, ocean_pid, registered_players, [{player, position} | rest_of_turns]) do
    turn(ocean_pid, player, position)
    |> take_turn(turn_results, registered_players, player)
    |> take_turns(ocean_pid, registered_players, rest_of_turns)
  end

  defp take_turn({_, _, :no_ocean_yet}, turn_results, _registered_players, player) do
    Logger.info("#{player} is trying to take a turn before there is an ocean")
    turn_results
  end
  defp take_turn(turn, turn_results, registered_players, _player) do
    turn_results ++ [ notify_players(turn, registered_players) ]
  end

  defp turn(ocean_pid, player, position) do
    case Ocean.strike(ocean_pid, position) do
      true  -> {player, position, :hit}
      false -> {player, position, :miss}
      _     -> {player, position, :no_ocean_yet}
    end
  end

  defp notify_players(turn_result, registered_players) do
    Enum.each(registered_players, fn {player, player_pid} -> 
      Logger.info("Notifying '#{player}' of turn #{inspect turn_result}")
      send player_pid, turn_result
    end)

    turn_result
  end
end
