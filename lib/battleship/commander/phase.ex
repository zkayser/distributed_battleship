defmodule Phase do
  def run(context, phases) do
    for_phase_context(context)
    |> setup_phase_parameters(context)
    |> run_phase_action(context.phase, phases)
    |> update_context(context) 
  end

  def for_phase_context(context) do
    phase = context.phase
    case context do
      %{^phase => phase_context} -> phase_context
      _                          -> %{}
    end
  end

  def setup_phase_parameters(phase_context, %{service: service}) do
    Map.merge(phase_context, %{service: service})
  end
  def setup_phase_parameters(phase_context, _) do
    phase_context
  end

  def run_phase_action(phase_context, phase, phases) do
    phase_action = Keyword.get(phases, phase)
    phase_action.(phase_context)
  end

  def update_context(phase_context = %{new_phase: new_phase}, context) do
    Map.merge(context, %{context.phase => phase_context, old_phase: context.phase, phase: new_phase})
  end
  def update_context(phase_context, context) do
    Map.merge(context, %{context.phase => phase_context, old_phase: context.phase})
  end

  # Indicate that a phase change is required.
  def change(trigger_pid) do
    Trigger.pull(trigger_pid)
  end
  def change?(trigger_pid, state, change_func) do
    case Trigger.pulled?(trigger_pid) do
      true  -> change_func.(state)
      false -> state
    end
  end
end

