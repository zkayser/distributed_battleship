defmodule GameCommander do
  alias GameCommander

  require Logger

  @phases [
    none:                &StartApp.tick/1,
    waiting_for_players: &WaitingForPlayers.tick/1,
    start_game:          &GameCommander.noop/1,
    adding_ships:        &GameCommander.noop/1,
    taking_turns:        &GameCommander.noop/1,
    feedback:            &GameCommander.noop/1,
    scoreboard:          &GameCommander.noop/1,
    finish:              &GameCommander.noop/1
  ]

  def noop(phase_context) do
    phase_context
  end

  def valid_phase?(phase) do
    phase in phase_names()
  end

  def phase_names() do
    Keyword.keys(@phases)
  end

  def phases() do
    @phases
  end

  # MAIN Application Start
  def start() do
    spawn_link(__MODULE__, :play, [])
  end

  def play() do
    play(:none, Context.new(), @phases)
  end

  def play(phase, context) do
    play(phase, context, @phases)
  end

  def play(:finish, context, _) do
    track_phase(context, :finish)
  end
  def play(phase, context, phases) do
    context = set_phase(context, phase)

    {phase_action, phase_context} = allocate_phase_context(context, phase, phases)

    phase_context = phase_action.(phase_context)

    {phase_context, new_phase} = update_phase(phase_context, phase)

    context = update_context(context, phase_context, new_phase)
    
    Logger.debug("#{__MODULE__}: PHASE #{phase} => #{new_phase} : #{inspect Map.delete(context, :track_phase)}")

    pause(context[:tick_rate_ms])

    play(new_phase, context, phases)
  end

  defp set_phase(context, phase) do
    context
      |> Map.merge(%{phase: phase})
      |> track_phase(phase)
  end

  defp allocate_phase_context(context, phase, phases) do
    phase_action = Keyword.get(phases, phase)

    phase_context = case context do
      %{^phase => phase_context} -> phase_context
      _                                        -> %{}
    end

    {phase_action, phase_context}
  end

  defp update_phase(phase_context = %{new_phase: new_phase}, _) do
    {Map.delete(phase_context, :new_phase), new_phase }
  end
  defp update_phase(phase_context, phase) do
    {phase_context, phase}
  end

  defp update_context(context, phase_context, new_phase) do
    context
    |> Map.merge(%{context.phase => phase_context, phase: new_phase})
    |> Map.update(:tick_count, 1, &(&1 + 1))
  end

  defp pause(nil), do: :ok
  defp pause(tick_rate_ms) do
    :timer.sleep(tick_rate_ms)
  end

  defp track_phase(context = %{track_phase: track_phase}, phase) do
    %{context | track_phase: track_phase ++ [phase]}
  end
  defp track_phase(context, phase) do
    Map.merge(context, %{track_phase: [phase]})
  end
end


