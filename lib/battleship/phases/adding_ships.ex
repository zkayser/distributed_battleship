defmodule AddingShips do
  @moduledoc "allow players to tell the commander where there ships will be"

  def tick(phase_context = %{trigger_pid: trigger_pid}) do
    Phase.change?(trigger_pid, phase_context, :taking_turns)
  end
end

