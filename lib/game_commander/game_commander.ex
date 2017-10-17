defmodule GameCommander do

  @fsm %{
    :wait_for_players => :start_game,
    :start_game => :adding_ships,
    :adding_ships => :taking_turns,
    :taking_turns => :feedback,
    :feedback => :scoreboard
  }

  # States
  # :wait_for_players
  # :start_game
  # :adding_ships
  # :taking_turns
  # :feedback
  # :scoreboard
  #
  def new() do
    %{state: :wait_for_players}
  end

  def start(phases) do
    start(phases, new())
  end

  def start(phases, context) do
    run_each_phase(context, phases)
  end

  defp run_each_phase(context, []), do: context
  defp run_each_phase(context, [phase|the_rest]) do
    context = context 
              |> Map.merge(phase.(context))
              |> run_each_phase(the_rest)

    Map.update(context, :state, :wait_for_players, fn old_state -> @fsm[old_state] end)
  end

end

