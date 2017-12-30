defmodule Mix.Tasks.Battleship.NextPhase do
  use Mix.Task

  @shortdoc "Trigger a phase change"

  def run(_) do
    Battleship.Command.puts(:trigger, fn trigger_pid ->
      Trigger.pull(trigger_pid)
      {:ok, "Changing phase"}
    end)
  end
end

