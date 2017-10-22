defmodule GameCommander do

  require Logger

  @actions [
    none:             &GameCommander.noop/1,
    wait_for_players: &WaitingForPlayers.tick/1,
    start_game:       &GameCommander.noop/1,
    adding_ships:     &GameCommander.noop/1,
    taking_turns:     &GameCommander.noop/1,
    feedback:         &GameCommander.noop/1,
    scoreboard:       &GameCommander.noop/1,
    finish:           &GameCommander.noop/1
  ]

  def noop(context) do
    Map.merge(context, %{new_state: context.state})
  end

  def states() do
    Keyword.keys(@actions)
  end

  def actions() do
    @actions
  end

  # MAIN Application Start
  def start() do
    context = %{
      tick_count: 0,
      tick_rate_ms: 1000,
      node_self: Node.self(),
      node_cookie: Node.get_cookie(),
    }
    play(:none, context, @actions)
  end

  def start(state, context) do
    play(state, context, @actions)
  end

  def start(state, context, actions) do
    play(state, context, actions)
  end

  defp play(:finish, context, _), do: context
  defp play(state, context, actions) do
    context = Map.merge(context, %{state: state})

    action = Keyword.get(actions, state)
    context = action.(context)

    new_state = context.new_state
    context = Map.delete(context, :new_state)
    context = Map.update(context, :tick_count, 1, &(&1 + 1))

    Logger.debug("#{__MODULE__}: STATE #{state} => #{new_state} : #{inspect context}")

    pause(context[:tick_rate_ms])

    play(new_state, context, actions)
  end

  defp pause(nil), do: false
  defp pause(tick_rate_ms) do
    :timer.sleep(tick_rate_ms)
  end
end
