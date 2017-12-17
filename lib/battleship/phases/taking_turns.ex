defmodule TakingTurns do
  @moduledoc """
    Each player can, throw bombs at any time. Those turns are compiled and evaulated each tick.
  """

  require Logger
  
  def tick(phase_context = %{turn_count: turn_count, service: %{ocean_pid: ocean_pid, turns_pid: turns_pid}}) do
    turns = Turns.get(turns_pid)

    turn_results = process([], ocean_pid, turns)
    phase_context = Map.merge(phase_context, %{turn_results: turn_results})

    Map.merge(phase_context, %{turn_count: turn_count + length(turns)})
  end

  def tick(phase_context) do
    Map.merge(phase_context, %{turn_count: 0})
  end

  defp process(turn_results, _cean_pid, []), do: turn_results
  defp process(turn_results, ocean_pid, [{player, position} | turns]) do
    process(turn_results ++ [evaulate(ocean_pid, player, position)], ocean_pid, turns)
  end

  defp evaulate(ocean_pid, player, position) do
    case Ocean.hit?(ocean_pid, position) do
      true  -> {player, position, :hit}
      false -> {player, position, :miss}
    end
  end
end
