defmodule GameCommander do
  def start(state, context, actions) do
    play(state, context, actions)
  end

  defp play(:finish, context, _), do: context
  defp play(state, context, actions) do
    context = actions[state].(context)

    new_state = context.new_state
    context = Map.delete(context, :new_state)
    context = Map.update(context, :tick_count, 1, &(&1 + 1))

    IO.puts(">>>> #{state} => #{new_state} : #{inspect context}")

    play(new_state, context, actions)
  end
end
