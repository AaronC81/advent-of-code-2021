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

    # Build a map of pairs to counts for the template
    # Just a raw list is far too inefficient for large numbers of pair insertions
    template_pairs = Enum.chunk_every(template, 2, 1, :discard)
    template_map =
      Map.keys(rules)
      |> Enum.map(fn pair -> {pair, Enum.count(template_pairs, & &1 == pair)} end)
      |> Map.new()

    # Also build a map of individual elements to their counts
    template_elements = Enum.frequencies(template)

    {{template_map, template_elements}, rules}
  end

  def pair_insertion({pair_counts, element_counts}, rules) do
    # From the AoC example, NNCB becomes NCNBCHB
    #
    # The rule NN -> C means that NN produces NC and CN
    # The rule NC -> B means that NC produces NB and BC
    # The rule CB -> H means that CB produces CH and HB
    #
    # The pattern is that AB -> C produces AC and CB

    Enum.reduce(
      # For each pair and count...
      pair_counts,

      # ...build a new pair count map and element count map...
      {%{}, element_counts},

      # ...by adding both pairs produced from insertion onto the map keys, and adding to the element
      # count for the middle element
      fn {pair, count}, {new_pair_counts, new_element_counts} ->
        middle = rules[pair]
        [a, b] = pair

        new_pair_1 = [a, middle]
        new_pair_2 = [middle, b]

        {
          Map.update(new_pair_counts, new_pair_1, count, & &1 + count)
          |> Map.update(new_pair_2, count, & &1 + count),

          Map.update(new_element_counts, middle, 0, & &1 + count)
        }
      end
    )
  end

  def pair_insertions(polymer, rules, count) do
    Enum.reduce(1..count, polymer, fn i, p ->
      IO.puts(i)
      pair_insertion(p, rules)
    end)
  end

  def most_least_diff({_, element_counts}) do
    most = Map.values(element_counts) |> Enum.max
    least = Map.values(element_counts) |> Enum.min

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
