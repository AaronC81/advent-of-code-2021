Code.require_file("lib/aoc_utils.exs")

defmodule Day11 do
  defmodule Point do
    defstruct x: 0, y: 0
  end

  def load_octopi() do
    array =
      AOC.read_input("day11")
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    # For much faster indexing, convert into a map of points to heights
    # (Elixir arrays are linked lists)
    # This is copied from Day 9
    Enum.with_index(array)
    |> Enum.flat_map(fn {row, y} ->
      Enum.with_index(row)
      |> Enum.map(fn {energy, x} ->
        {%Point{x: x, y: y}, String.to_integer(energy)}
      end)
    end)
    |> Map.new()
  end

  def step(octopi) do
    # Increment all the energy levels to get a new map
    octopi =
      octopi
      |> Enum.map(fn {pt, nrg} -> {pt, nrg + 1} end)
      |> Map.new

    # Figure out the flashes
    propagate_flashes(octopi)
  end

  def propagate_flashes(octopi), do: propagate_flashes(octopi, [])
  def propagate_flashes(octopi, already_flashed) do
    # Find points with an energy level over 9, and that weren't already flashed
    points_to_flash =
      octopi
      |> Enum.filter(fn {pt, nrg} -> nrg > 9 && !(pt in already_flashed) end)
      |> Enum.map(fn {pt, _} -> pt end)

    # From these, find the list of all adjacent points
    # (This could contain the same points multiple times, e.g. if we have a formation like 9 1 9)
    points_to_increment_after_flash = Enum.flat_map(points_to_flash, fn pt ->
      [
        # Horizontals
        %Point{x: pt.x - 1, y: pt.y},
        %Point{x: pt.x + 1, y: pt.y},

        # Verticals
        %Point{x: pt.x, y: pt.y - 1},
        %Point{x: pt.x, y: pt.y + 1},

        # Diagonals
        %Point{x: pt.x - 1, y: pt.y - 1},
        %Point{x: pt.x - 1, y: pt.y + 1},
        %Point{x: pt.x + 1, y: pt.y + 1},
        %Point{x: pt.x + 1, y: pt.y - 1},
      ]
    end)

    # Since points may appear more than once, convert into a map of counts
    point_increases_after_flash =
      Enum.reduce(points_to_increment_after_flash, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

    # Create a new map with these points increased accordingly
    octopi =
      octopi
      |> Enum.map(fn {pt, nrg} -> {pt, nrg + (point_increases_after_flash[pt] || 0)} end)
      |> Map.new

    # Did any points actually flash?
    if Enum.empty?(points_to_flash) do
      # No - now we can reset energies of octopi which flashed to 0, and return this map
      octopi =
        Enum.map(octopi, fn {pt, nrg} ->
          {
            pt,
            if pt in already_flashed do
              0
            else
              nrg
            end
          }
        end)
        |> Map.new

      {octopi, length(already_flashed)}
    else
      # Yes - recurse
      propagate_flashes(octopi, points_to_flash ++ already_flashed)
    end
  end

  def part1(octopi) do
    {_, final_count} = Enum.reduce(
      1..100,
      {octopi, 0},
      fn _, {octopi, count} ->
        {new_octopi, add_count} = Day11.step(octopi)
        {new_octopi, count + add_count}
      end
    )
    final_count
  end

  def part2(octopi, step_number \\ 1) do
    # Keep recursing until every octopus flashed on the same step
    {octopi, flash_count} = Day11.step(octopi)
    if flash_count == map_size(octopi) do
      step_number
    else
      part2(octopi, step_number + 1)
    end
  end
end

part1 = Day11.part1(Day11.load_octopi)
IO.puts("Part 1: #{part1}")

part2 = Day11.part2(Day11.load_octopi)
IO.puts("Part 1: #{part2}")
