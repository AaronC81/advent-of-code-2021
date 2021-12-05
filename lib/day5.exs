Code.require_file("lib/aoc_utils.exs")

defmodule Day5 do
  defmodule Point do
    defstruct x: 0, y: 0
  end

  defmodule Line do
    defstruct start: nil, end: nil
  end

  def load_lines() do
    # Construct lines of points using regex
    Regex.scan(~r"(\d+),(\d+) -> (\d+),(\d+)", AOC.read_input("day5"))
    |> Enum.map(fn [_ | numbers] ->
      [sx, sy, ex, ey] = Enum.map(numbers, &String.to_integer/1)
      %Line{start: %Point{x: sx, y: sy}, end: %Point{x: ex, y: ey}}
    end)
  end

  def points_on_line(line, include_diagonals \\ false) do
    # Is this line horizontal or vertical?
    cond do
      line.start.y == line.end.y ->
        # Horizontal
        (line.start.x..line.end.x) |> Enum.map(&%Point{x: &1, y: line.start.y})

      line.start.x == line.end.x ->
        # Vertical
        (line.start.y..line.end.y) |> Enum.map(&%Point{x: line.start.x, y: &1})

      abs(line.start.x - line.end.x) == abs(line.start.y - line.end.y) ->
        # Diagnoal
        if include_diagonals do
          Enum.zip(line.start.x..line.end.x, line.start.y..line.end.y)
          |> Enum.map(fn {x, y} -> %Point{x: x, y: y} end)
        else
          []
        end
    end
  end

  def build_overlap_grid(lines, include_diagonals \\ false) do
    points = Enum.flat_map(lines, &points_on_line(&1, include_diagonals))
    points_map = Enum.reduce(points, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

    for y <- 0..1000 do
      for x <- 0..1000 do
        # Enum.count(points, &(&1 == %Point{x: x, y: y}))
        points_map[%Point{x: x, y: y}] || 0
      end
    end
  end

  def count_overlaps(grid) do
    Enum.map(grid, fn row ->
      Enum.filter(row, &(&1 >= 2))
      |> Enum.count
    end)
    |> Enum.sum
  end
end

lines = Day5.load_lines()

part1 = Day5.count_overlaps(Day5.build_overlap_grid(lines, false))
IO.puts("Part 1: #{part1}")

part2 = Day5.count_overlaps(Day5.build_overlap_grid(lines, true))
IO.puts("Part 1: #{part2}")
