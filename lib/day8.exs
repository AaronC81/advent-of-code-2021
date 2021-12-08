Code.require_file("lib/aoc_utils.exs")

defmodule Day8 do
  @doc "One entry of 10 signal values, and the 4 digits shown on the display."
  defmodule Display do
    defstruct signals: nil, digits: nil
  end

  def load_displays() do
    AOC.read_input("day8")
    |> String.split("\n")
    |> Enum.map(fn line ->
      # Split on | and convert each side to list of set of characters
      [signals, digits] =
        String.split(line, "|")
        |> Enum.map(fn part ->
          String.split(part)
          |> Enum.map(&String.graphemes/1)
          |> Enum.map(&MapSet.new/1)
        end)

      %Display{signals: signals, digits: digits}
    end)
  end

  @doc "Count the occurrences of 1, 4, 7, and 8 shown in the list of displays."
  def part1(displays) do
    # Count the obvious numbers (1, 7, 4, 8) in each display, and sum them
    displays
    |> Enum.map(fn display ->
      Enum.count(display.digits, fn seg -> case MapSet.size(seg) do
        2 -> true # Digit 1
        3 -> true # Digit 7
        4 -> true # Digit 4
        7 -> true # Digit 8
        _ -> false # Do not count anything else
      end end)
    end)
    |> Enum.sum
  end

  # The actual segments are laid out like this:
  #    aaaa
  #   b    c
  #   b    c
  #    dddd
  #   e    f
  #   e    f
  #    gggg

  @doc """
  Through a series of steps, discovers which signals map to which segments, and returns a mapping.
  """
  def deduce_mapping(display) do
    # Find the signals for 7 and 1
    # (7 and 1 can be found easily because they're the only digits with 3 and 2 segments
    # respectively)
    signals_7 = Enum.find(display.signals, & MapSet.size(&1) == 3)
    signals_1 = Enum.find(display.signals, & MapSet.size(&1) == 2)

    # The signal controlling segment A is the difference between 7 and 1
    segment_a_signal = MapSet.difference(signals_7, signals_1)

    # Find the five segment signals
    five_segment_signals = Enum.filter(display.signals, & MapSet.size(&1) == 5)

    # Let's identify the signals of 3 - this is the only five-segment number which entirely overlaps
    # with the segments of 7
    signals_3 = Enum.find(five_segment_signals, & MapSet.subset?(signals_7, &1))

    # We can now subtract the signals of 3 from the signals of 4 to find the signal controlling B
    # (4 can be found easily because it's the only digit with 4 segments)
    signals_4 = Enum.find(display.signals, & MapSet.size(&1) == 4)
    segment_b_signal = MapSet.difference(signals_4, signals_3)

    # Find the signals which all five-segment numbers have in common, and find which of these
    # signals is also used in 4 - this gives us the signal controlling segment D
    five_segment_signals_in_common = Enum.reduce(five_segment_signals, &MapSet.intersection/2)
    segment_d_signal = MapSet.intersection(signals_4, five_segment_signals_in_common)

    # Now we know the signals for A, B, and D. The only five-segment number containing all of these
    # is 5, so we can find the signals for 5
    signals_5 = Enum.find(five_segment_signals, &
      MapSet.subset?(segment_a_signal, &1)
      && MapSet.subset?(segment_b_signal, &1)
      && MapSet.subset?(segment_d_signal, &1)
    )

    # We can find the signal controlling segment F by finding the one signal where 5 intersects 1
    signals_1 = Enum.find(display.signals, & MapSet.size(&1) == 2)
    segment_f_signal = MapSet.intersection(signals_1, signals_5)

    # We identified which of the five-segment numbers were 3 and 5, and there's only one more, 2, so
    # we can easily find that
    signals_2 = Enum.find(five_segment_signals, & &1 != signals_5 && &1 != signals_3)

    # 5 and 2 intersect at A, D, and G. We've found the signals for A and D but not G, so we can
    # deduce the signal controlling G from that intersection
    segment_g_signal =
      MapSet.intersection(signals_2, signals_5)
      |> MapSet.difference(segment_a_signal)
      |> MapSet.difference(segment_d_signal)

    # The segment controlling C is where digits 2 and 1 intersect
    segment_c_signal = MapSet.intersection(signals_2, signals_1)

    # And finally! There's only segment left to deduce, E, so we can just remove every other segment
    # from the set of possible ones
    segment_e_signal =
      MapSet.new(String.graphemes("abcdefg"))
      |> MapSet.difference(segment_a_signal)
      |> MapSet.difference(segment_b_signal)
      |> MapSet.difference(segment_c_signal)
      |> MapSet.difference(segment_d_signal)
      |> MapSet.difference(segment_f_signal)
      |> MapSet.difference(segment_g_signal)

    # Build map, unwrapping the sets
    %{
      Enum.at(segment_a_signal, 0) => "a",
      Enum.at(segment_b_signal, 0) => "b",
      Enum.at(segment_c_signal, 0) => "c",
      Enum.at(segment_d_signal, 0) => "d",
      Enum.at(segment_e_signal, 0) => "e",
      Enum.at(segment_f_signal, 0) => "f",
      Enum.at(segment_g_signal, 0) => "g",
    }
  end

  @doc "Using a deduced mapping, converts a displayed digit (char set of signals) to an integer."
  def displayed_digit_to_integer(digit, mapping) do
    # Map signals to segments
    segments = MapSet.new(Enum.map(digit, & mapping[&1]))

    # Figure out which digit is displayed
    s = fn x -> MapSet.new(String.graphemes(x)) end
    cond do
      segments == s.("acfgeb")  -> 0
      segments == s.("cf")      -> 1
      segments == s.("acdeg")   -> 2
      segments == s.("acdfg")   -> 3
      segments == s.("bcdf")    -> 4
      segments == s.("abdfg")   -> 5
      segments == s.("abdefg")  -> 6
      segments == s.("acf")     -> 7
      segments == s.("abcdefg") -> 8
      segments == s.("abcdfg")  -> 9
    end
  end

  @doc """
  Used a deduced mapping, converts a displayed number (list of char set of signals) to an integer.
  """
  def displayed_number_to_integer(number, mapping) do
    [thou, hun, ten, one] = Enum.map(number, & displayed_digit_to_integer(&1, mapping))
    thou * 1000 + hun * 100 + ten * 10 + one
  end

  @doc "For each display, deduce the mapping, find the displayed number, and sum them."
  def part2(displays) do
    displays
    |> Enum.map(fn display ->
      mapping = deduce_mapping(display)
      displayed_number_to_integer(display.digits, mapping)
    end)
    |> Enum.sum
  end
end

display = Day8.load_displays()

IO.puts "Part 1: #{Day8.part1(display)}"
IO.puts "Part 2: #{Day8.part2(display)}"
