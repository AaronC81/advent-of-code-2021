Code.require_file("lib/aoc_utils.exs")

defmodule Day14 do
  def load_template_and_rules() do
    [template | [_ | rules]] =
      AOC.read_input("day14")
      |> String.split("\n")

    template = String.graphemes(template)

    # Build a map out of the rules
    rules =
      Enum.map(rules, fn line ->
        #A  B     -  >     R
        [a, b, _, _, _, _, r] = String.graphemes(line)
        {[a, b], r}
      end)
      |> Map.new

    {template, rules}
  end

  def pair_insertion(polymer, rules) do
    # Iterate over each pair of elements in the polymer, but also keep the last element on its own
    #   e.g. [["N", "N"], ..., ["B"]]
    Enum.chunk_every(polymer, 2, 1)
    # Look up in rules and insert in middle
    # The end of one pair is the start of the next, so we don't duplicate them
    |> Enum.flat_map(fn
      [a, b] -> [a, rules[[a, b]]]
      [b] -> [b]
    end)
  end

  def pair_insertions(polymer, rules, count) do
    Enum.reduce(1..count, polymer, fn i, p ->
      IO.puts(i)
      pair_insertion(p, rules)
    end)
  end

  def most_least_diff(polymer) do
    occurrences = Enum.frequencies_by(polymer, & &1)
    most = occurrences |> Map.values |> Enum.max
    least = occurrences |> Map.values |> Enum.min

    most - least
  end
end

{template, rules} = Day14.load_template_and_rules

after_10 = Day14.pair_insertions(template, rules, 10)
part1 = Day14.most_least_diff(after_10)
IO.puts("Part 1: #{part1}")

after_40 = Day14.pair_insertions(template, rules, 40)
part2 = Day14.most_least_diff(after_40)
IO.puts("Part 2: #{part2}")
