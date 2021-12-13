Code.require_file("lib/aoc_utils.exs")

defmodule Day13 do
  defmodule Point do
    defstruct x: 0, y: 0
  end

  defmodule Fold do
    defstruct axis: nil, loc: nil
  end

  def load_points_and_folds() do
    {folds, points} =
      AOC.read_input("day13")
      |> String.split("\n")
      |> Enum.reject(& &1 == "")
      |> Enum.split_with(& String.starts_with?(&1, "fold along"))

    points =
      Enum.map(points, fn point ->
        [x, y] = String.split(point, ",")
        %Point{x: String.to_integer(x), y: String.to_integer(y)}
      end)
      |> MapSet.new

    folds = Enum.map(folds, fn fold ->
      # "fold along x=3" - split on spaces ([_, _, "x=3"]) then "=" (["x", "3"])
      ["fold", "along", axis_and_loc] = String.split(fold)
      [axis, loc] = String.split(axis_and_loc, "=")

      %Fold{axis: String.to_atom(axis), loc: String.to_integer(loc)}
    end)

    {points, folds}
  end

  def perform_fold(points, fold) do
    Enum.map(points, fn point ->
      cond do
        # Need to fold this point up
        fold.axis == :y && point.y > fold.loc ->
          %Point{x: point.x, y: fold.loc * 2 - point.y}

        # Need to fold this point left
        fold.axis == :x && point.x > fold.loc ->
          %Point{x: fold.loc * 2 - point.x, y: point.y}

        # Don't need to fold
        true -> point
      end
    end)
    |> MapSet.new
  end

  def perform_folds(points, folds) do
    Enum.reduce(folds, points, fn fold, pts -> perform_fold(pts, fold) end)
  end

  def visualise_points(points) do
    # Find width and height of diagram
    max_x = (Enum.map(points, & &1.x) |> Enum.max)
    max_y = (Enum.map(points, & &1.y) |> Enum.max)

    # Construct string
    Enum.map(0..max_y, fn y ->
      Enum.map(0..max_x, fn x ->
        if %Point{x: x, y: y} in points do
          "#"
        else
          " "
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end
end

{points, folds} = Day13.load_points_and_folds()

part1 =
  Day13.perform_fold(points, Enum.at(folds, 0))
  |> MapSet.size
IO.puts("Part 1: #{part1}")

part2 =
  Day13.perform_folds(points, folds)
  |> Day13.visualise_points()
IO.puts("Part 2:\n#{part2}")
