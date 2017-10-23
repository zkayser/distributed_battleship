defmodule StartApp do
  require Logger

  def tick(phase_context) do
    Logger.debug("#{__MODULE__}: starting app")

    Map.merge(phase_context, %{new_phase: :waiting_for_players})
  end
end
