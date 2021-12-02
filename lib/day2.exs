Code.require_file("lib/aoc_utils.exs")

defmodule Day2 do
  def instructions() do
    AOC.read_input("day2")
    # Split on lines and whitespace
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    # Convert to list of tuples of {atom, integer}
    |> Enum.map(fn [inst, mag] ->
      {mag, ""} = Integer.parse(mag)
      inst = String.to_atom(inst)
      {inst, mag}
    end)
  end

  defmodule P1SubmarineState do
    defstruct depth: 0, hpos: 0
  end

  def part1() do
    List.foldl(
      instructions(),
      %P1SubmarineState{},
      &p1move/2
    )
  end

  # Fancy parameter pattern matching
  def p1move({:forward, mag}, submarine), do: %{ submarine | hpos:  submarine.hpos  + mag }
  def p1move({:up, mag}, submarine),      do: %{ submarine | depth: submarine.depth - mag }
  def p1move({:down, mag}, submarine),    do: %{ submarine | depth: submarine.depth + mag }

  defmodule P2SubmarineState do
    defstruct depth: 0, hpos: 0, aim: 0
  end

  def part2() do
    List.foldl(
      instructions(),
      %P2SubmarineState{},
      &p2move/2
    )
  end

  def p2move({:forward, mag}, submarine) do
    %{ submarine | hpos: submarine.hpos + mag, depth: submarine.depth + submarine.aim * mag }
  end
  def p2move({:up, mag}, submarine),      do: %{ submarine | aim: submarine.aim - mag }
  def p2move({:down, mag}, submarine),    do: %{ submarine | aim: submarine.aim + mag }
end

IO.write("Part 1: ")
part1 = Day2.part1
IO.inspect(part1)
IO.puts("  Multiplied: #{part1.hpos * part1.depth}")

IO.write("Part 2: ")
part2 = Day2.part2
IO.inspect(part2)
IO.puts("  Multiplied: #{part2.hpos * part2.depth}")
