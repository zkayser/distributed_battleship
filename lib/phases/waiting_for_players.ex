defmodule WaitingForPlayers do
  @moduledoc """
  * Once the Game Commander is started players will have 60s to start their player and connect.
  """

  require Logger

  def tick(context = %{waiting_for_players: %{players_pid: pid, wait_start: wait_start, wait_max: wait_max}}) do
    Logger.debug("#{__MODULE__}: update")

    context = Map.merge(context, 
      %{waiting_for_players:
        Map.merge(context.waiting_for_players,
          %{
            player_count: Players.player_count(pid)
          }),
        new_state: :waiting_for_players
      }
    )

    context = cond do
      DateTime.diff(DateTime.utc_now, wait_start) >= wait_max -> 
        Map.merge(context, %{new_state: :start_game})
      true -> context
    end

    context
  end

  def tick(context) do
    Logger.debug("#{__MODULE__}: initialize")

    new_context = 
      %{
        new_state: :waiting_for_players,
        waiting_for_players: 
          %{
            players_pid: Players.start(),
            player_count: 0,
            wait_max: 60,
            wait_start: DateTime.utc_now
          },
      }

    case Map.has_key?(context, :waiting_for_players) do
      true  -> update_in(new_context, [:waiting_for_players], 
                  fn waiting_for_players -> Map.merge(waiting_for_players, context.waiting_for_players) end)
      false -> new_context
    end
  end
end
