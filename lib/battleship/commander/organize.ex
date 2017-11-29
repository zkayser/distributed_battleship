defmodule Organize do
  require Logger

  def play(phase, context, phases) do
    context
    |> track_phase(phase)
    |> for_phase(phase)
    |> run_phase(phases)
    |> update_tick_count()
    |> wait_for_tick()
    |> logger()
  end

  def track_phase(context = %{track_phase: track_phase}, phase) do
    %{context | track_phase: track_phase ++ [phase]}
  end
  def track_phase(context, phase) do
    Map.merge(context, %{track_phase: [phase]})
  end

  defp for_phase(context, phase) do
    context
      |> Map.merge(%{phase: phase})
  end

  defp run_phase(context, phases) do
    Phase.run(context, phases)
  end

  defp update_tick_count(context) do
    context
    |> Map.update(:tick_count, 1, &(&1 + 1))
  end

  defp wait_for_tick(context) do
    pause(context[:tick_rate_ms])
    context
  end

  defp pause(nil), do: :ok
  defp pause(tick_rate_ms) do
    :timer.sleep(tick_rate_ms)
  end

  defp logger(context = %{old_phase: old_phase, phase: new_phase}) do
    Logger.debug("#{__MODULE__}: PHASE #{old_phase} => #{new_phase} : #{inspect Map.delete(context, :track_phase)}")
    context
  end
  defp logger(context = %{phase: new_phase}) do
    Logger.debug("#{__MODULE__}: PHASE _____ => #{new_phase} : #{inspect Map.delete(context, :track_phase)}")
    context
  end
  defp logger(context) do
    Logger.debug("#{__MODULE__}: PHASE _____ => _____ : #{inspect Map.delete(context, :track_phase)}")
    context
  end
end

