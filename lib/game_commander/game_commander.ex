defmodule GameCommander do
  alias GameCommander

  require Logger

  @phases [
    none:                &StartApp.tick/1,
    waiting_for_players: &WaitingForPlayers.tick/1,
    start_game:          &StartGame.tick/1,
    adding_ships:        &AddingShips.tick/1,
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

  def initialize() do
    context = 
      Context.new() 
      |> Map.merge(%{service: 
        %{
          players_pid: Players.start(),
          ocean_pid:   Ocean.start()
        }
      })

    Logger.info("Players service starting: #{inspect context.service}")

    context
  end

  def play() do
    play(:none, initialize(), @phases)
  end

  def play(phase, context) do
    play(phase, context, @phases)
  end

  def play(:finish, context, _) do
    Organize.track_phase(context, :finish)
  end
  def play(phase, context, phases) do
    context = Organize.play(phase, context, phases)
   
    play(context.phase, context, phases)
  end
end

defmodule Organize do
  require Logger

  def play(phase, context, phases) do
    context
    |> for_phase(phase)
    |> run_phase(phases)
    |> update_tick_count()
    |> wait_for_tick()
    |> logger()
  end

  defp for_phase(context, phase) do
    context
      |> Map.merge(%{phase: phase})
      |> track_phase(phase)
  end

  defp run_phase(context, phases) do
    Phase.run(context, phases)
  end

  defp update_tick_count(context) do
    context
    |> Map.update(:tick_count, 1, &(&1 + 1))
  end

  defp wait_for_tick(context) do
    pause(context[:tick_rate_ms])
    context
  end

  defp logger(context = %{old_phase: old_phase, phase: new_phase}) do
    Logger.debug("#{__MODULE__}: PHASE #{old_phase} => #{new_phase} : #{inspect Map.delete(context, :track_phase)}")
    context
  end
  defp logger(context = %{phase: new_phase}) do
    Logger.debug("#{__MODULE__}: PHASE _____ => #{new_phase} : #{inspect Map.delete(context, :track_phase)}")
    context
  end
  defp logger(context) do
    Logger.debug("#{__MODULE__}: PHASE _____ => _____ : #{inspect Map.delete(context, :track_phase)}")
    context
  end

  defp pause(nil), do: :ok
  defp pause(tick_rate_ms) do
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
  def run(context, phases) do
    for_phase_context(context)
    |> setup_phase_parameters(context)
    |> run_phase_action(context.phase, phases)
    |> update_context(context) 
  end

  def for_phase_context(context) do
    phase = context.phase
    case context do
      %{^phase => phase_context} -> phase_context
      _                          -> %{}
    end
  end

  def setup_phase_parameters(phase_context, %{service: service}) do
    Map.merge(phase_context, %{service: service})
  end
  def setup_phase_parameters(phase_context, _) do
    phase_context
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

