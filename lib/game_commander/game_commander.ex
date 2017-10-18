defmodule GameCommander do
  def start(state, actions) do
    context = %{}

    actions[state].(context)

    Map.update(context, :tick_count, 1, &(&1 + 1))
  end
end
