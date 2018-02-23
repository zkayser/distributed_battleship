defmodule Mix.Tasks.Battleship.NextPhase do
  use Mix.Task

  @shortdoc "Trigger a phase change"

  def run(commander_ip) do
    Battleship.Command.puts(commander_ip, :trigger, fn trigger_pid ->
      Trigger.pull(trigger_pid)
      {:ok, "Changing phase"}
    end)
  end
end

