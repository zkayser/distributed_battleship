defmodule StartApp do
  require Logger

  def tick(phase_context) do
    Logger.debug("#{__MODULE__}: starting app")

    Phase.change(phase_context, :waiting_for_players)
  end
end
