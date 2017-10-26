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
    Organize.track_phase(context, :finish)
  end
  def play(phase, context, phases) do
    context = 
      context
      |> Organize.for_phase(phase)
      |> Organize.run_phase(phases)
      |> Organize.update_tick_count()
      |> Organize.wait_for_tick()
      |> Organize.logger()
    
    play(context.phase, context, phases)
  end
end

defmodule Organize do
  require Logger

  def for_phase(context, phase) do
    context
      |> Map.merge(%{phase: phase})
      |> track_phase(phase)
  end

  def run_phase(context, phases) do
    Phase.for_phase_context(context)
    |> Phase.run_phase_action(context.phase, phases)
    |> Phase.update_context(context) 
  end

  def update_tick_count(context) do
    context
    |> Map.update(:tick_count, 1, &(&1 + 1))
  end

  def wait_for_tick(context) do
    pause(context[:tick_rate_ms])
    context
  end

  def logger(context = %{old_phase: old_phase, new_phase: new_phase}) do
    Logger.debug("#{__MODULE__}: PHASE #{old_phase} => #{new_phase} : #{inspect Map.delete(context, :track_phase)}")
    context
  end
  def logger(context = %{new_phase: new_phase}) do
    Logger.debug("#{__MODULE__}: PHASE _____ => #{new_phase} : #{inspect Map.delete(context, :track_phase)}")
    context
  end
  def logger(context) do
    Logger.debug("#{__MODULE__}: PHASE _____ => _____ : #{inspect Map.delete(context, :track_phase)}")
    context
  end

  def pause(nil), do: :ok
  def pause(tick_rate_ms) do
    :timer.sleep(tick_rate_ms)
  end

  def track_phase(context = %{track_phase: track_phase}, phase) do
    %{context | track_phase: track_phase ++ [phase]}
  end
  def track_phase(context, phase) do
    Map.merge(context, %{track_phase: [phase]})
  end
end

defmodule Phase do
  def for_phase_context(context) do
    phase = context.phase
    case context do
      %{^phase => phase_context} -> phase_context
      _                          -> %{}
    end
  end

  def run_phase_action(phase_context, phase, phases) do
    phase_action = Keyword.get(phases, phase)
    phase_action.(phase_context)
  end

  def update_context(phase_context = %{new_phase: new_phase}, context) do
    Map.merge(context, %{context.phase => phase_context, old_phase: context.phase, phase: new_phase})
  end
  def update_context(phase_context, context) do
    Map.merge(context, %{context.phase => phase_context, old_phase: context.phase})
  end
end

