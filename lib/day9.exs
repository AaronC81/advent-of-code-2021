Code.require_file("lib/aoc_utils.exs")

defmodule Day9 do
  defmodule Point do
    defstruct x: 0, y: 0
  end

  def load_heightmap() do
    array =
      AOC.read_input("day9")
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    # For much faster indexing, convert into a map of points to heights
    # (Elixir arrays are linked lists)
    Enum.with_index(array)
    |> Enum.flat_map(fn {row, y} ->
      Enum.with_index(row)
      |> Enum.map(fn {height, x} ->
        {%Point{x: x, y: y}, String.to_integer(height)}
      end)
    end)
    |> Map.new()
  end

  def adjacent_heights(heightmap, point) do
    # Try to get all points, this will give us nils if we're at a corner
    [
      %Point{x: point.x - 1, y: point.y    },
      %Point{x: point.x,     y: point.y - 1},
      %Point{x: point.x + 1, y: point.y    },
      %Point{x: point.x,     y: point.y + 1},
    ]
    |> Enum.map(& {&1, heightmap[&1]})
    # Filter out those nils
    |> Enum.reject(fn {_, h} -> is_nil(h) end)
    # Convert to map
    |> Map.new()
  end

  def low_point?(heightmap, point) do
    adjacent_heights(heightmap, point)
    |> Map.values()
    |> Enum.all?(fn adj -> adj > heightmap[point] end)
  end

  def low_points(heightmap) do
    Map.keys(heightmap)
    |> Enum.filter(& low_point?(heightmap, &1))
  end

  def risk_level(heightmap, point) do
    heightmap[point] + 1
  end

  def basin_points(heightmap, start, covered \\ nil)
  def basin_points(heightmap, start, nil), do: basin_points(heightmap, start, MapSet.new([start]))
  def basin_points(heightmap, start, covered) do
    # Find the adjacent points higher than this one (since the basin flows down to the start point)
    # which we haven't already covered
    adj_basin_points =
      adjacent_heights(heightmap, start)
      |> Enum.filter(fn {_, h} -> h > heightmap[start] && h != 9 end)
      |> Enum.map(fn {pt, _} -> pt end)
      |> Enum.reject(& &1 in covered)
      |> MapSet.new()

    # Add these to the covered list
    covered = MapSet.union(adj_basin_points, covered)

    # Recurse with these points and union returns
    recursed =
      Enum.map(adj_basin_points, & basin_points(heightmap, &1, covered))
      |> Enum.reduce(MapSet.new, &MapSet.union/2)

    MapSet.union(covered, recursed)
  end
end

heightmap = Day9.load_heightmap
low_points = Day9.low_points(heightmap)

part1 =
  low_points
  |> Enum.map(& Day9.risk_level(heightmap, &1))
  |> Enum.sum
IO.puts("Part 1: #{part1}")

part2 =
  low_points
  |> Enum.map(& Day9.basin_points(heightmap, &1))
  |> Enum.sort_by(&MapSet.size/1)
  |> Enum.reverse()
  |> Enum.take(3)
  |> Enum.map(&MapSet.size/1)
  |> Enum.product()
IO.puts("Part 2: #{part2}")
