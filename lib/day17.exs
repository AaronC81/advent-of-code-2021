Code.require_file("lib/aoc_utils.exs")

defmodule Day17 do
  defmodule TargetArea do
    defstruct x1: nil, x2: nil, y1: nil, y2: nil
  end

  def load_target_area() do
    [_, x1, x2, y1, y2] =
      Regex.run(~r"target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)", AOC.read_input("day17"))

    %TargetArea{
      x1: String.to_integer(x1),
      x2: String.to_integer(x2),
      y1: String.to_integer(y1),
      y2: String.to_integer(y2),
    }
  end

  def trace_trajectory(target, {vx, vy}, {x, y} \\ {0, 0}) do
    cond do
      # We overshot the target area
      # (Assumes negative Y target area)
      x > target.x2 || y < target.y1 -> {:miss, []}

      # We hit the target area!
      x in target.x1..target.x2 && y in target.y1..target.y2 -> {:hit, []}

      # We're still on our way
      true ->
        # Calculate new point and velocity
        next_point = {x + vx, y + vy}
        next_velocity = {
          # Drag
          cond do
            vx < 0 -> vx + 1
            vx > 0 -> vx - 1
            vx == 0 -> 0
          end,

          # Gravity
          vy - 1
        }

        {result, points} = trace_trajectory(target, next_velocity, next_point)
        {result, [next_point] ++ points}
    end
  end

  def highest_y(points) do
    points
    |> Enum.map(fn {_, y} -> y end)
    |> Enum.max
  end

  def find_all_hit_trajectories(target) do
    # Build a very large set of initial velocities to try
    initial_velocities = Enum.flat_map(target.y1..1000, fn y ->
      Enum.map(0..target.x2, fn x ->
        {x, y}
      end)
    end)

    # Find the one which yields the trajectory which goes the highest
    Enum.filter(initial_velocities, fn velocity ->
      case Day17.trace_trajectory(target, velocity) do
        {:hit, _} -> true
        {:miss, _} -> false
      end
    end)
  end
end

target = Day17.load_target_area
hit_trajectories = Day17.find_all_hit_trajectories(target)

part1 =
  Enum.map(hit_trajectories, fn traj ->
    {:hit, points} = Day17.trace_trajectory(target, traj)
    Day17.highest_y(points)
  end)
  |> Enum.max
IO.puts("Part 1: #{part1}")

part2 = length(hit_trajectories)
IO.puts("Part 2: #{part2}")
