defmodule StartGame do
  def run(context) do
    Map.merge(context, %{state: :adding_ships})
  end
end

