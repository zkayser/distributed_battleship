defmodule Mix.Tasks.Battleship.ChangePhase do
  use Mix.Task

  @shortdoc "Trigger a phase change"

  def run(_) do
    Battleship.Command.command(:trigger, fn trigger_pid ->
      Trigger.pull(trigger_pid)
    end)
  end
end

