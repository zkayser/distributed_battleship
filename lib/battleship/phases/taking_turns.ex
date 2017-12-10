defmodule TakingTurns do
  @moduledoc """
    Each player can, throw bombs at any time. Those turns are compiled and evaulated each tick.
  """

  require Logger
  
  def tick(phase_context) do

    Logger.info "Turn #{inspect phase_context}"

    phase_context
  end
end
