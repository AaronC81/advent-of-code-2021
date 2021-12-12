Code.require_file("lib/aoc_utils.exs")

defmodule Day12 do
  def load_paths() do
    # Load list of bidirectional paths from input, e.g.
    #   A-b
    #   b-c
    # Becomes: [{"A", "b"}, {"b", "A"}, {"b", "c"}, {"c", "b"}]
    paths =
      AOC.read_input("day12")
      |> String.split("\n")
      |> Enum.flat_map(fn line ->
        [a, b] = String.split(line, "-")
        [{a, b}, {b, a}]
      end)

    # For easier processing, convert this into a map of which caves can be reached from where
    # %{"A" => ["b"], "b" => ["A", "c"], "c" => ["b"]}
    Enum.reduce(paths, %{}, fn {from, to}, map ->
      # Insert blank list if key doesn't exist already
      map = Map.put_new(map, from, [])

      # Add this mapping
      map = Map.put(map, from, Map.get(map, from) ++ [to])

      map
    end)
  end

  def explore_routes(map, from \\ "start",  one_small_cave_twice \\ false, small_caves_visits \\ %{})
  def explore_routes(_, "end", _, _), do: [["end"]]
  def explore_routes(map, from, one_small_cave_twice, small_caves_visits) do
    # Explore each possible path from here, unless it's a small cave we already visited
    Map.get(map, from)
    |> Enum.filter(fn cave ->
      # Work out the visit limit right now
      visit_limit = if one_small_cave_twice do
        # Has a small cave been visited twice yet?
        if Enum.any?(small_caves_visits, fn {_, count} -> count > 1 end) do
          # Yes - only one visit allowed for all future caves
          1
        else
          # No - allowed to visit this once or twice
          2
        end
      else
        # Only one visit to a small cave allowed
        1
      end

      # Never allowed to visit start twice...
      cave != "start"
      # ...and can't exceed the visit limit
      && small_caves_visits[cave] == nil || small_caves_visits[cave] < visit_limit
    end)
    |> Enum.flat_map(fn to ->
      # Recurse, incrementing visit count if it's a small cave
      subroutes =
        if to == String.downcase(to) do
          small_caves_visits = Map.put(small_caves_visits, to, (small_caves_visits[to] || 0) + 1)
          explore_routes(map, to, one_small_cave_twice, small_caves_visits)
        else
          explore_routes(map, to, one_small_cave_twice, small_caves_visits)
        end

      # Add our "from" cave onto each returned cave
      subroutes |> Enum.map(& [from] ++ &1)
    end)
  end
end

map = Day12.load_paths()

part1 = length(Day12.explore_routes(map))
IO.puts("Part 1: #{part1}")

part2 = length(Day12.explore_routes(map, "start", true))
IO.puts("Part 2: #{part2}")
