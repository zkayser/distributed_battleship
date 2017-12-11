defmodule Ocean do
  require Logger

  # Every player needs an area to work in or ships will be too close together.
  @player_ocean_ratio      10
  @player_ocean_ship_ratio 0.75

  def start() do
    {:ok, pid} = GenServer.start_link(Ocean.Server, %{ships: []}, name: {:global, :ocean})

    pid
  end

  def stop(), do: stop(:global.whereis_name(:ocean))
  def stop(:undefined), do: {:ok, "Already Stopped"}
  def stop(pid) do
    case Process.alive?(pid) do
      true  -> GenServer.call(pid, {:stop})
      false -> {:ok, "Aleady Stopped"}
    end
  end

  # Ocean size is a function of the number of players 
  def size(pid, registered_players) do
    ocean_size = Enum.count(Map.keys(registered_players)) * @player_ocean_ratio
    max_ship_parts = round(ocean_size * @player_ocean_ship_ratio )

    GenServer.call(pid, {:set_size, ocean_size, max_ship_parts})
  end
  def size(pid) do
    GenServer.call(pid, {:get_size})
  end

  def ships(pid) do
    GenServer.call(pid, {:ships})
  end

  def add_ship(pid, player, from_x, from_y, to_x, to_y) do
    GenServer.call(pid, {:add_ship, Ship.new(player, from_x, from_y, to_x, to_y)})
  end

  def hit?(pid, position) do
    case GenServer.call(pid, {:hit?, position}) do
      {:ok, :hit}  -> true
      {:ok, :miss} -> false
    end
  end

  def strikes(pid) do
    {:ok, result} = GenServer.call(pid, {:strikes})
    result
  end
end

#
# State
# - player
# - ships
# - ocean_size
# - max_ship_parts
#
defmodule Ocean.Server do
  use GenServer
  require Logger

  # All ships must be at least 2 parts long.
  @min_ship_length         2

  def handle_call({:set_size, ocean_size, max_ship_parts}, _from_pid, state) do
    {:reply, {:ok, ocean_size, max_ship_parts}, Map.merge(state, %{ocean_size: ocean_size, max_ship_parts: max_ship_parts})} 
  end

  def handle_call({:get_size}, _from_pid, state) do
    {:reply, {:ok, state.ocean_size, state.max_ship_parts}, state} 
  end

  def handle_call({:ships}, _from_pid, state) do
    {:reply, {:ok, state.ships}, state} 
  end

  def handle_call({:add_ship, %{player: player, from: %{from_x: from_x, from_y: from_y}, to: %{to_x: to_x, to_y: to_y}}}, from_pid, 
                  state = %{ships: _hips, ocean_size: _cean_size, max_ship_parts: _ax_ship_parts}) do
    handle_call({:add_ship, Ship.new(player, from_x, from_y, to_x, to_y)}, from_pid, state)
  end
  def handle_call({:add_ship, ship = %Ship{player: player}}, _from_pid, 
                  state = %{ships: ships, ocean_size: ocean_size, max_ship_parts: max_ship_parts}) do

    {reply, state} = with {:ok} <- valid_ship_orientation(ship),
                          {:ok} <- valid_ship_on_ocean(ocean_size, ship),
                          {:ok} <- valid_ship_long_enough(ship),
                          {:ok} <- valid_number_ship_parts(max_ship_parts, player, ship, ships),
                          {:ok} <- valid_clear_water(player, ship, ships)
    do
      {{:ok, "Added"}, Map.merge(state, %{ships: ships ++ [ship]})}
    else
      {:error, message} -> {{:error, message}, state }
    end

    {:reply, reply, state}
  end
  def handle_call({:add_ship, _}, _from_pid, state) do
    {:reply, {:error, "how big the ocean blue"}, state}
  end

  def handle_call({:hit?, %{x: x, y: y}}, _from_pid, state = %{ships: ships}) do
    strike = Ship.new("strike", x, y, x, y )

    case Enum.any?(ships, fn ship -> on_top_of(strike, ship) end) do
      true  -> 
        {:reply, {:ok, :hit}, Map.merge(state, %{ships: Enum.reduce(ships, [], fn ship, acc -> acc ++ [Ship.strike(ship, x, y)] end)})}
      false -> 
        {:reply, {:ok, :miss}, state}
    end
  end

  # TODO refactor this one.
  def handle_call({:strikes}, _rom_pid, state) do
    strikes = Enum.reduce(state.ships, %{}, fn ship, acc -> 

      count = case Map.has_key?(acc, ship.player) do
        true  -> acc[ship.player]
        false -> 0
      end

      strike_count = length(ship.strikes)

      Map.merge(acc, %{ship.player => count + strike_count})
    end)

    {:reply, {:ok, strikes}, state}
  end

  def handle_call({:stop}, _from_pid, state) do
    {:stop, :normal, {:ok, "Stopped"}, state}
  end

  def handle_call(command, _from_pid, state) do
    Logger.info("Invalid command #{inspect command} : #{inspect state}")
    {:noreply, state}
  end

  defp valid_ship_orientation(ship) do
    cond do
      ship.from.x == ship.to.x -> {:ok}
      ship.from.y == ship.to.y -> {:ok}
      true                     -> {:error, "ship must be horizontal or vertical"}
    end
  end

  defp valid_ship_on_ocean(ocean_size, ship) do
    case {ship.from.x >= 0         , ship.from.y >= 0         , ship.to.x >= 0         , ship.to.y >= 0,
          ship.from.x < ocean_size , ship.from.y < ocean_size , ship.to.x < ocean_size , ship.to.y < ocean_size } do
      {true, true, true, true, true, true, true, true} -> {:ok}
      _                                                -> {:error, "off the ocean: should be within 0x0 and #{ocean_size - 1}x#{ocean_size - 1}"}
    end
  end

  defp valid_ship_long_enough(ship) do
    case ship_length(ship) >= @min_ship_length do
      true  -> {:ok}
      false -> {:error, "ships must be longer then 1 part"}
    end
  end

  defp valid_number_ship_parts(max_ship_parts, player, ship, ships) do
    current_ship_parts = count_players_ships(ships, player)
    new_ship_parts     = ship_length(ship)

    case current_ship_parts + new_ship_parts <= max_ship_parts do
     true  -> {:ok}
     false -> {:error, "ship limit exceeded: you have #{current_ship_parts} and are adding #{new_ship_parts} ship parts. Max is #{max_ship_parts}"}
    end
  end

  defp valid_clear_water(_, this_ship, ships) do
    case Enum.count(ships, fn ship -> on_top_of(this_ship, ship) end) do
      0 -> {:ok}
      _ -> {:error, "there is another ship here"}
    end

  end

  defp count_players_ships(ships, player) do
    Enum.reduce(ships, 0, fn ship, count -> 
      case ship do
        %Ship{player: ^player} -> count + ship_length(ship)
        _                      -> count
      end
    end)
  end

  # TODO push ship length into Ship module.
  defp ship_length(ship) do
    cond do
      ship.from.x == ship.to.x -> abs(ship.from.y - ship.to.y) + 1
      ship.from.y == ship.to.y -> abs(ship.from.x - ship.to.x) + 1
      true                     -> 99
    end
  end

  defp on_top_of(this_ship, that_ship) do
    Collision.intersect(
        {this_ship.from.x, this_ship.from.y},
        {this_ship.to.x,   this_ship.to.y},
        {that_ship.from.x, that_ship.from.y},
        {that_ship.to.x,   that_ship.to.y}
      )
  end
end

