defmodule TakingTurns do
  @moduledoc """
    Each player can, throw bombs at any time. Those turns are compiled and evaulated each tick.
  """

  require Logger
  
  def tick(phase_context = %{turn_count: turn_count, registered_players: registered_players, service: %{ocean_pid: ocean_pid, turns_pid: turns_pid}}) do
    turns = Turns.get(turns_pid)

    turn_results = take_turns([], ocean_pid, registered_players, turns)

    Map.merge(phase_context, %{turn_count: turn_count + length(turns), turn_results: turn_results})
  end

  def tick(phase_context = %{service: %{players_pid: players_pid}}) do
    {:ok, registered_players} = Players.registered_players(players_pid)

    Map.merge(phase_context, %{
      turn_count: 0,
      registered_players: registered_players
    })
  end

  defp take_turns(turn_results, _cean_pid, _egistered_players, []), do: turn_results
  defp take_turns(turn_results, ocean_pid, registered_players, [{player, position} | turns]) do
    take_turns(turn_results ++ [
      turn(ocean_pid, player, position)
      |> notify_player(registered_players)
    ], ocean_pid, registered_players, turns)
  end

  defp turn(ocean_pid, player, position) do
    case Ocean.strike(ocean_pid, position) do
      true  -> {player, position, :hit}
      false -> {player, position, :miss}
    end
  end

  defp notify_player(turn_result = {player, _osition, _esult}, registered_players) do
    send registered_players[player], turn_result

    turn_result
  end
end
