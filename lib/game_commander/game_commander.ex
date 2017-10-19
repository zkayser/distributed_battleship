defmodule GameCommander do
  @actions [
    none:             &GameCommander.noop/1,
    wait_for_players: &GameCommander.noop/1,
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

    IO.puts(">>>> #{state} => #{new_state} : #{inspect context}")

    play(new_state, context, actions)
  end
end
