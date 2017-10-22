defmodule StartApp do
  require Logger

  def tick(context) do
    Logger.debug("#{__MODULE__}: starting app")

    Map.merge(context, %{new_state: :waiting_for_players})
  end
end
