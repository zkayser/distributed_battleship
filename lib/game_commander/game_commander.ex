defmodule GameCommander do

  @fsm %{
    :wait_for_players => :start_game,
    :start_game => :adding_ships,
    :adding_ships => :taking_turns,
    :taking_turns => :feedback,
    :feedback => :scoreboard
  }

  def new() do
    %{state: :wait_for_players}
  end

  def phases() do
    [
      &WaitingForPlayers.run/1,
      &StartGame.run/1
    ]
  end

  def start() do
    start(phases())
  end

  def start(phases) do
    start(phases, new())
  end

  def start(phases, context) do
    run_each_phase(context, phases)
  end

  defp run_each_phase(context, []), do: context
  defp run_each_phase(context, [phase|other_phases]) do
    context = context 
              |> Map.merge(phase.(context))
              |> run_each_phase(other_phases)

    Map.update(context, :state, :wait_for_players, fn old_state -> @fsm[old_state] end)
  end

end

