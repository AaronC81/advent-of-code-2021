Code.require_file("lib/aoc_utils.exs")

defmodule Day15 do
  def load_map() do
    # Load as a 2D array first
    array =
      AOC.read_input("day15")
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    # Convert into hash
    size = length(array) # It's a square

    Enum.flat_map(0..(size - 1), fn y ->
      Enum.map(0..(size - 1), fn x ->
        {{x, y}, String.to_integer(Enum.at(Enum.at(array, y), x))}
      end)
    end)
    |> Map.new
  end

  def load_part2_map() do
    # Load original map and get its size
    map = load_map()
    size =
      Map.keys(map)
      |> Enum.max
      |> then(fn {s, _} -> s + 1 end)

    # Duplicate 5 times in both directions, incrementing each risk level (or wrapping from 9 to 1)
    map
    |> Enum.flat_map(fn {{x, y}, r} ->
      Enum.flat_map(0..4, fn w ->
        Enum.map(0..4, fn h ->
          new_r = r + w + h
          new_r = if new_r > 9 do new_r - 9 else new_r end

          {{size * w + x, size * h + y}, new_r}
        end)
      end)
    end)
    |> Map.new
  end

  def safest_path_riskiness(map) do
    # Construct initial map of riskinesses - all infinite, except origin which is 0
    # Each of these is the total riskiness of the best path to reach this location
    riskinesses =
      Map.keys(map)
      |> Enum.map(& {&1, 9999999999})
      |> Map.new
      |> Map.put({0, 0}, 0)

    # Build the risk levels of the safest paths to each point
    safest_riskinesses = build_safest_path(map, riskinesses, MapSet.new, MapSet.new(Map.keys(map)))

    # Get risk level of path to end
    {_, rl} = Enum.max_by(safest_riskinesses, fn {k, _} -> k end)
    rl
  end

  def build_safest_path(map, riskinesses, visited, unvisited) do
    if MapSet.size(visited) == 0 do
      # If nothing's visited, start with the origin
      build_safest_path(
        map,
        refine_safest_path(map, {0, 0}, riskinesses, visited),
        MapSet.put(visited, {0, 0}),
        MapSet.delete(unvisited, {0, 0})
      )
    else
      # Print occasional status update
      if rem(MapSet.size(visited), 100) == 0 do
        IO.puts("#{MapSet.size(visited)} visited, #{MapSet.size(unvisited)} left")
      end

      # Pick the unvisited location with the lowest current riskiness
      if MapSet.size(unvisited) == 0 do
        # We're done!
        riskinesses
      else
        next_visit_location = Enum.min_by(unvisited, & riskinesses[&1])
        build_safest_path(
          map,
          refine_safest_path(map, next_visit_location, riskinesses, visited),
          MapSet.put(visited, next_visit_location),
          MapSet.delete(unvisited, next_visit_location)
        )
      end
    end
  end

  def refine_safest_path(map, {x, y}, riskinesses, visited) do
    risk_here = riskinesses[{x, y}]

    # Find the best path through this location to its neighbours
    neighbour_locs = [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1},
    ]
    neighbour_riskinesses =
      neighbour_locs
      |> Enum.reject(& &1 in visited) # Reject visited
      |> Enum.map(& {&1, map[&1]})
      |> Enum.reject(fn {_, r} -> r == nil end) # Reject out-of-bounds
      |> Enum.map(fn {k, r} -> {k, r + risk_here} end)

    # Are any of them better than their previous found location?
    # If so, replace them, and return new riskinesses
    neighbour_riskinesses
    |> Enum.reduce(riskinesses, fn {neighbour, new_risk}, risks ->
      if risks[neighbour] > new_risk do
        Map.put(risks, neighbour, new_risk)
      else
        risks
      end
    end)
    |> Map.new
  end
end

part1 = Day15.safest_path_riskiness(Day15.load_map())
IO.puts("Part 1: #{part1}")

part2 = Day15.safest_path_riskiness(Day15.load_part2_map())
IO.puts("Part 2: #{part2}")
