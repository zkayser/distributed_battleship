defmodule GameCommanderTest do
  use ExUnit.Case

  def fake_phase(phase_context = %{test_phases: [next_phase | rest_of_phases]}) do
    Map.merge(phase_context, %{new_phase: next_phase, test_phases: rest_of_phases})
  end

  def fake_phase(phase_context = %{stop_next_call: true}) do
    Map.merge(Map.delete(phase_context, :stop_next_call), %{new_phase: :finish} )
  end

  def fake_phase(phase_context) do
    Map.merge(phase_context, %{stop_next_call: true} )
  end

  describe "tick" do
    test "trigger an action on a tick" do
      context = GameCommander.play(:none,
        %{
            GameCommanderTest => %{ test_phases: [:finish] }
        }, [none: &GameCommanderTest.fake_phase/1])

      assert context.tick_count == 1
    end

    test "run two ticks" do
      phases = [
        none: &GameCommanderTest.fake_phase/1,
        finish: &GameCommanderTest.fake_phase/1
      ]

      context = GameCommander.play(:none, 
        %{         
          GameCommanderTest => %{test_phases: [:none, :finish]}
        }, phases)

      assert context.tick_count == 2
    end
  end

  describe "all the phases" do
    test "change phases" do
      phases = Enum.map(GameCommander.phases, fn {name, _} ->
        {name, &GameCommanderTest.fake_phase/1}
      end)

      context = GameCommander.play(:none, 
        %{
          GameCommanderTest => %{test_phases: GameCommander.phase_names}
        }, phases)

      assert context.tick_count == 8
    end

    test "dont chnage phase is there is no new_state" do
      context = GameCommander.play(
        :none, 
        %{ GameCommanderTest => %{} },
        [none: &GameCommanderTest.fake_phase/1])

      assert context.track_phase == [:none, :none, :finish]
    end
    
  end

  test "should ensure that a phase name is spelled correctly" do
    refute GameCommander.valid_phase?(nil)
    refute GameCommander.valid_phase?("")
    refute GameCommander.valid_phase?(:invalid)

    Enum.each GameCommander.phase_names(), fn phase ->
      assert GameCommander.valid_phase?(phase)
    end
  end
  
end

