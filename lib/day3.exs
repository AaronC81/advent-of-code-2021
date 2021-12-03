Code.require_file("lib/aoc_utils.exs")

defmodule Day3 do
  # [["1", "0", "1", ...], ...]
  def binary_numbers() do
    AOC.read_input("day3")
    # Split on lines and characters
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  def most_common_digits(numbers, if_equal \\ nil) do
    numbers_count = length(numbers)
    digits_count = length(List.first(numbers))

    # Iterate through each "column" of digits
    Enum.map((0..digits_count-1), fn i ->
      # Count the number of 1s in this column
      ones = Enum.map(numbers, &(Enum.at(&1, i))) |> Enum.count(&(&1 == "1"))

      # If it's greater than half of the count of numbers, then we have more 1s than 0s
      cond do
        ones > (numbers_count / 2) -> "1"
        ones < (numbers_count / 2) -> "0"
        true -> if_equal
      end
    end)
  end

  def invert(number) do
    Enum.map(number, fn d -> case d do
      "1" -> "0"
      "0" -> "1"
    end end)
  end

  def to_integer(number) do
    {i, ""} = Integer.parse(Enum.join(number), 2)
    i
  end

  def gamma_rate() do
    to_integer(most_common_digits(binary_numbers()))
  end

  def epsilon_rate() do
    to_integer(invert(most_common_digits(binary_numbers())))
  end

  def part2(commonality, numbers \\ nil, bit_index \\ nil) do
    case {numbers, bit_index} do
      # If called with one or both parameters nil, recurse with them set up
      {nil, _} -> part2(commonality, binary_numbers(), bit_index)
      {_, nil} -> part2(commonality, numbers,          0        )

      # If there is only one number left, terminate and return it
      {[item], _} -> to_integer(item)

      # If none are left, something went wrong
      {[], _} -> raise "no solutions"

      # Normal case - reduce to only numbers containing the most common digit, and recurse
      _ ->
        most_common_digit = Enum.at(most_common_digits(numbers, "1"), bit_index)

        # Flip if we're actually looking for the least common digit
        filter_digit = case {commonality, most_common_digit} do
          {:most, _} -> most_common_digit
          {:least, "0"} -> "1"
          {:least, "1"} -> "0"
        end

        # Recurse with new set of numbers matching this digit
        filtered_numbers = Enum.filter(numbers, &(Enum.at(&1, bit_index) == filter_digit))
        part2(commonality, filtered_numbers, bit_index + 1)
    end
  end

  def oxygen_generator_rating() do
    part2(:most)
  end

  def co2_scrubber_rating() do
    part2(:least)
  end
end

IO.puts("Power consumption (part 1): #{Day3.gamma_rate * Day3.epsilon_rate}")
IO.puts("Life support (part 2): #{Day3.oxygen_generator_rating * Day3.co2_scrubber_rating}")
