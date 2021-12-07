Code.require_file("lib/aoc_utils.exs")

defmodule Day7 do
  def load_positions() do
    AOC.read_input("day7")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def constant_rate_fuel_usage(positions) do
    # The position with optimal fuel usage will be the median
    sorted_positions = Enum.sort(positions)
    target = Enum.at(sorted_positions, round(length(sorted_positions) / 2))

    Enum.map(positions, fn pos -> abs(target - pos) end)
    |> Enum.sum
  end

  def increasing_rate_fuel_usage(positions) do
    # Maybe there's a clever way to find the optimal target position. But I don't know what it is!
    # Just search through... It's still very fast
    search_range = Enum.min(positions)..Enum.max(positions)

    Enum.map(search_range, fn target ->
      # Calculate cost if we use this particular element as the target
      Enum.map(positions, fn pos ->
        if target == pos do 0 else Enum.sum(1..abs(target - pos)) end
      end)
      |> Enum.sum
    end)
    # Find and return best
    |> Enum.min
  end
end

positions = Day7.load_positions()

part1 = Day7.constant_rate_fuel_usage(positions)
IO.puts "Part 1: #{part1}"

part2 = Day7.increasing_rate_fuel_usage(positions)
IO.puts "Part 2: #{part2}"
