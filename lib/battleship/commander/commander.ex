defmodule Commander do
  alias Commander

  require Logger

  @phases [
    none:                &StartApp.tick/1,
    waiting_for_players: &WaitingForPlayers.tick/1,
    start_game:          &StartGame.tick/1,
    adding_ships:        &AddingShips.tick/1,
    taking_turns:        &Commander.noop/1,
    feedback:            &Commander.noop/1,
    scoreboard:          &Commander.noop/1,
    finish:              &Commander.noop/1
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
          ocean_pid:   Ocean.start(),
          trigger_pid: Trigger.start()
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


