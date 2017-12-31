defmodule Ui do

  @graphic_zero_zero "/"
  @graphic_water     "~"
  @graphic_strike    "X"

  def render(:text, ocean_size, data) do
    players = active_players(data.ships)

    ocean = render_each_position(ocean_size, data.ships)
    roster = render_players(players)

    Enum.join(ocean ++ roster)
  end

  defp active_players(ships) do
    Enum.dedup_by(ships, fn ship -> ship.player end)
    |> Enum.reduce(%{}, fn ship, acc -> Map.merge(acc, %{ship.player => player_code(ship.player)}) end)
  end

  defp player_code(player) do
    player
    |> String.first
    |> String.capitalize
  end

  defp render_players(players) do
    ["\n"]
    ++ Enum.map(players, fn {player, code} ->
      "#{code}: #{player}\n"
    end)
  end

  defp render_each_position(ocean_size, ships) do
    render_header(ocean_size) ++ render_row(ocean_size, ships)
  end

  defp render_header(ocean_size) do
    [@graphic_zero_zero, " "] 
    ++ for number <- (0..ocean_size-1) do "#{rem(number, 10)}" end 
    ++ ["\n"]
  end

  defp render_row(ocean_size, ships) do
    range = 0..ocean_size-1
    for y <- range, x <- range do
      render_position(x, y, ocean_size - 1, ships)
    end
  end

  defp render_position(x, y, _cean_limit, ships) when x == 0 do
    "#{y} #{choose_graphic(x, y, ships)}"
  end

  defp render_position(x, y, ocean_limit, ships) when x == ocean_limit do
    choose_graphic(x, y, ships) <> "\n"
  end
  defp render_position(x, y, _cean_limit, ships) do
    choose_graphic(x, y, ships)
  end

  defp choose_graphic(x, y, ships) do
    ocean_position = Position.new(x, y)

    ship = Enum.find(ships, false, fn ship -> Ship.at?(ship, ocean_position) end)
    was_struck = case ship do
      false -> false
      _     -> Ship.struck?(ship, ocean_position)
    end

    graphic(ship, was_struck)
  end

  defp graphic(_ship = false, _was_struck = false), do: @graphic_water
  defp graphic(ship, _was_struck = false), do: player_code(ship.player)
  defp graphic(_ship, _was_struck = true ), do: @graphic_strike
end

