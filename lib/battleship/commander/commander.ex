defmodule Commander do
  alias Commander

  require Logger

  @phases [
    none:                &StartApp.tick/1,
    waiting_for_players: &WaitingForPlayers.tick/1,
    start_game:          &StartGame.tick/1,
    adding_ships:        &AddingShips.tick/1,
    taking_turns:        &TakingTurns.tick/1,
    finish:              &Finish.tick/1
  ]

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
          trigger_pid: Trigger.start(),
          turns_pid:   Turns.start()
        }
      })

    Logger.info("Players service starting: #{inspect context.service}")

    context
  end

  # TODO let the supervisors deal with shutdown
  def deinitialize() do
    Logger.info("Deinitialize")
    Players.stop()
    Ocean.stop()
    Trigger.stop()
    Turns.stop()
  end

  def play() do
    context = initialize()

    play(:none, context, @phases)

    deinitialize()

    Logger.info("The End")
    System.stop(0)
  end

  def play(phase, context), do: play(phase, context, @phases)

  def play(_, context = %{finish: %{game_over: true}}, _), do: context
  def play(phase, context, phases) do
    context = Organize.play(phase, context, phases)
   
    play(context.phase, context, phases)
  end
end


