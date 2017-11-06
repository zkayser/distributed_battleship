defmodule AddingShips do
  @moduledoc "allow players to tell the commander where there ships will be"

  def tick(phase_context = %{wait_max: wait_max, wait_start: wait_start}) do
    wait_time = DateTime.diff(DateTime.utc_now, wait_start)
    cond do
      wait_time >= wait_max -> Map.merge(phase_context, %{new_phase: :taking_turns})
      true                  -> Map.merge(phase_context, %{new_phase: :adding_ships})
    end
  end

  def tick(phase_context) do
    new_phase_context = %{
      wait_max: 60,
      wait_start: DateTime.utc_now
    }

    Map.merge(new_phase_context, phase_context)
  end
end

