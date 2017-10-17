defmodule GameCommander do

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
    context 
    |> Map.merge(phase.(context))
    |> run_each_phase(the_rest)
  end

  def wait_for_players(context) do
    Map.merge(context, %{state: :start_game, players: [1]})
  end

  def start_game(context) do
    Map.merge(context, %{state: :adding_ships})
  end

end

