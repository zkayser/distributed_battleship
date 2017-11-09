defmodule CommanderTest do
  use ExUnit.Case

  setup() do
    on_exit(fn -> Players.stop() end)
  end

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
      context = Commander.play(:none,
        %{
            :none => %{ test_phases: [:finish] }
        }, [none: &CommanderTest.fake_phase/1])

      assert context.tick_count == 1
    end

    test "run two ticks" do
      phases = [
        none: &CommanderTest.fake_phase/1,
        finish: &CommanderTest.fake_phase/1
      ]

      context = Commander.play(:none, 
        %{         
          :none => %{test_phases: [:none,:finish]},
          :finish => %{test_phases: []}
        }, phases)

      assert context.tick_count == 2
    end
  end

  describe "all the phases" do
    test "change phases" do
      phases = Enum.map(Commander.phases, fn {name, _} ->
        {name, &CommanderTest.fake_phase/1}
      end)

      context = %{}
        |> Map.merge(%{none:                %{test_phases: [:waiting_for_players]}})
        |> Map.merge(%{waiting_for_players: %{test_phases: [:start_game]}})
        |> Map.merge(%{start_game:          %{test_phases: [:adding_ships]}})
        |> Map.merge(%{adding_ships:        %{test_phases: [:taking_turns]}})
        |> Map.merge(%{taking_turns:        %{test_phases: [:feedback]}})
        |> Map.merge(%{feedback:            %{test_phases: [:scoreboard]}})
        |> Map.merge(%{scoreboard:          %{test_phases: [:finish]}})

      context = Commander.play(:none, context, phases)

      assert context.tick_count == 7
    end

    test "dont chnage phase is there is no new_state" do
      context = Commander.play( :none, %{ :none => %{} }, [none: &CommanderTest.fake_phase/1])

      assert context.track_phase == [:none, :none, :finish]
    end
    
  end

  test "should ensure that a phase name is spelled correctly" do
    refute Commander.valid_phase?(nil)
    refute Commander.valid_phase?("")
    refute Commander.valid_phase?(:invalid)

    Enum.each Commander.phase_names(), fn phase ->
      assert Commander.valid_phase?(phase)
    end
  end

  describe "initialize the services" do
    test "players service is started" do
      context = Commander.initialize()

      assert context.service.players_pid, "didn't generate a players pid"
      assert context.service.ocean_pid, "didn't generate a ocean pid"
    end
  end

  describe "context to phase interface" do
    test "add service to phase data" do
      context = Phase.run(%{phase: :none, service: %{}}, [none: &CommanderTest.fake_phase/1]) 

      assert context.none
      assert context.none.service
    end

    test "add service to phase data when there is none" do
      context = Phase.run(%{phase: :none}, [none: &CommanderTest.fake_phase/1]) 

      assert context.none
      refute Map.has_key?(context.none, :service)
    end
  end
  
end

