defmodule WaitingForPlayers do
  @moduledoc """
  * Once the Game Commander is started players wil have 60s to start their player and connect.
  """

  def run(context) do
    Map.merge(context, %{players: [1]})
  end
end
