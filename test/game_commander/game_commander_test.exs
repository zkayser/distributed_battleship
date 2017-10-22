defmodule GameCommanderTest do
  use ExUnit.Case

  def fake_phase(phase_context) do
    Map.merge(phase_context, %{new_phase: hd(phase_context.test_phases), test_phases: tl(phase_context.test_phases)})
  end

  describe "tick" do
    test "trigger an action on a tick" do
      context = GameCommander.start(:none,
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

      context = GameCommander.start(:none, 
        %{         
          GameCommanderTest => %{test_phases: [:none, :finish]}
        }, phases)

      assert context.tick_count == 2
    end
  end

  describe "all the phases" do
    test "work through each phase" do
      phases = Enum.map(GameCommander.phases, fn {name, _} ->
        {name, &GameCommanderTest.fake_phase/1}
      end)

      context = GameCommander.start(:none, 
        %{
          GameCommanderTest => 
          %{test_phases: GameCommander.phase_names}
        }, phases)

      assert context.tick_count == 8
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

