defmodule GameCommander do

  # how would a full fsm work?
  def noop(_) do
  end

  def fsm() do
    %{
      #Old State,         Event      Action,                   New State
      {:none,             :next} => {&WaitingForPlayers.run/1, :wait_for_players},
      {:wait_for_players, :next} => {&StartGame.run/1,         :start_game},
      {:start_game,       :next} => {&GameCommander.noop/1,    :adding_ships},
      {:adding_ships,     :next} => {&GameCommander.noop/1,    :taking_turns},
      {:taking_turns,     :next} => {&GameCommander.noop/1,    :feedback},
      {:feedback,         :next} => {&GameCommander.noop/1,    :scoreboard}
    }
  end

  # Simple state sequence
  @fsm %{
    :none             => :wait_for_players,
    :wait_for_players => :start_game,
    :start_game       => :adding_ships,
    :adding_ships     => :taking_turns,
    :taking_turns     => :feedback,
    :feedback         => :scoreboard
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

