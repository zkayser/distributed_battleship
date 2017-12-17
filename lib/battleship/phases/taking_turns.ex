defmodule TakingTurns do
  @moduledoc """
    Each player can, throw bombs at any time. Those turns are compiled and evaulated each tick.
  """

  require Logger
  
  def tick(phase_context = %{turn_count: turn_count, service: %{ocean_pid: ocean_pid, turns_pid: turns_pid}}) do
    turns = Turns.get(turns_pid)

    turn_results = take_turns([], ocean_pid, turns)

    Map.merge(phase_context, %{turn_count: turn_count + length(turns), turn_results: turn_results})
  end

  def tick(phase_context) do
    Map.merge(phase_context, %{turn_count: 0})
  end

  defp take_turns(turn_results, _cean_pid, []), do: turn_results
  defp take_turns(turn_results, ocean_pid, [{player, position} | turns]) do
    take_turns(turn_results ++ [
      turn(ocean_pid, player, position)
    ], ocean_pid, turns)
  end

  defp turn(ocean_pid, player, position) do
    case Ocean.strike(ocean_pid, position) do
      true  -> {player, position, :hit}
      false -> {player, position, :miss}
    end
  end
end
