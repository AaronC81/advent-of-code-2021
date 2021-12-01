Code.require_file("lib/aoc_utils.exs")

defmodule Day1 do
  def measurements() do
    AOC.read_input("day1")
    |> String.split("\n")
    |> Enum.map(&Integer.parse/1)
    # parse returns a tuple containing leftover binary, discard that
    |> Enum.map(&elem(&1, 0))
  end

  def part1() do
    measurements()
    # Chunk into pairs: [[0, 1], [1, 2], [2, 3], ..., [last-1, last]]
    |> Enum.chunk_every(2, 1, :discard)
    # Count where increased
    |> Enum.count(fn [a, b] -> b > a end)
  end

  def part2() do
    measurements()
    # Chunk into the sliding windows: [[0, 1, 2], [1, 2, 3], ..., [last-2, last-1, last]]
    |> Enum.chunk_every(3, 1, :discard)
    # Convert every window into a sum
    |> Enum.map(&Enum.sum/1)
    # Iterate over pairs of window sums
    |> Enum.chunk_every(2, 1, :discard)
    # Count where increased
    |> Enum.count(fn [a, b] -> b > a end)
  end
end

IO.puts(Day1.part1())
IO.puts(Day1.part2())
