Code.require_file("lib/aoc_utils.exs")

defmodule Day6 do
  # Since every fish is identical besides its internal counter, the school of fish is represented by
  # a map of internal counters to quantities:
  #
  #   {0 => 12, 1 => 16, ..., 8 => 13}

  def load_fish() do
    AOC.read_input("day6")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
  end

  def step_day(school) do
    # In the new school, each count is "moved down" one key, to simulate each internal counter
    # decrementing
    new_school = for i <- 0..7, into: %{}, do: {i, school[i + 1]}

    # As well as this, every 0 becomes both a 6 and and 8
    new_school
    |> Map.put(6, (school[0] || 0) + (new_school[6] || 0))
    |> Map.put(8, (school[0] || 0))
  end

  def step_days(school, 0), do: school
  def step_days(school, days) do
    step_days(step_day(school), days - 1)
  end

  def count_fish(school) do
    Map.values(school) |> Enum.sum
  end
end

IO.puts("Part 1: #{Day6.count_fish(Day6.step_days(Day6.load_fish(), 80))}")
IO.puts("Part 2: #{Day6.count_fish(Day6.step_days(Day6.load_fish(), 256))}")
