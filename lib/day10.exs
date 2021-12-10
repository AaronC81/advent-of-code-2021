Code.require_file("lib/aoc_utils.exs")

defmodule Day10 do
  def load_lines() do
    AOC.read_input("day10")
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  def reverse_bracket(char) do
    case char do
      ")" -> "("
      "(" -> ")"
      "{" -> "}"
      "}" -> "{"
      "<" -> ">"
      ">" -> "<"
      "[" -> "]"
      "]" -> "["
    end
  end

  def validate(chars, stack \\ nil)
  def validate(chars, nil), do: validate(chars, [])

  # No characters left, and no expected close brackets
  def validate([], []), do: {:ok, nil}

  # No characters left, but some expected close brackets
  def validate([], stack), do: {:incomplete, stack}

  # Open bracket
  def validate([this_char | rest_chars], stack) when this_char in ["(", "<", "[", "{"] do
    validate(rest_chars, [reverse_bracket(this_char)] ++ stack)
  end

  # Close bracket
  def validate([this_char | rest_chars], [expected_match | rest_stack]) when this_char in [")", ">", "]", "}"] do
    if expected_match == this_char do
      # Valid
      validate(rest_chars, rest_stack)
    else
      {:corrupted, this_char}
    end
  end

  def score_corrupted(validation_result) do
    case validation_result do
      {:corrupted, ")"} -> 3
      {:corrupted, "]"} -> 57
      {:corrupted, "}"} -> 1197
      {:corrupted, ">"} -> 25137

      {:ok, _} -> 0
      {:incomplete, _} -> 0
    end
  end

  def score_incomplete(validation_result, base_score \\ 0) do
    case validation_result do
      {:incomplete, []} -> base_score
      {:incomplete, [next | rest]} ->
        added_score = case next do
          ")" -> 1
          "]" -> 2
          "}" -> 3
          ">" -> 4
        end
        # Recurse with new base score
        score_incomplete({:incomplete, rest}, base_score * 5 + added_score)

      {:ok, _} -> 0
      {:corrupted, _} -> 0
    end
  end
end

lines = Day10.load_lines()
validations = Enum.map(lines, &Day10.validate/1)

part1 =
  validations
  |> Enum.map(&Day10.score_corrupted/1)
  |> Enum.sum
IO.puts "Part 1: #{part1}"

part2 =
  validations
  |> Enum.map(&Day10.score_incomplete/1)
  |> Enum.sort
  |> Enum.reject(& &1 == 0)
  |> then(& Enum.at(&1, div(length(&1), 2)))
IO.puts "Part 2: #{part2}"
