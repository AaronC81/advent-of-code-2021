Code.require_file("lib/aoc_utils.exs")

# Elixir uses very chaotic bitwise operators:
#   &&&  AND
#   |||  OR
#   ~~~  NOT
use Bitwise

# Besides that, though, Elixir is GORGEOUS for bitwise operations; there's a built-in type called a
# bitstring which encodes an arbitrary sequence of bits, and we can pattern-match on these bits and
# convert chunks of them to integers.

defmodule Day16 do
  defmodule LiteralPacket do
    defstruct version: nil, data: nil
  end

  defmodule OperatorPacket do
    defstruct version: nil, subpackets: nil, operation: nil
  end

  def load_packet() do
    packet = AOC.read_input("day16")

    # Convert hex digits to list of bytes
    hex_digits = String.graphemes(packet)
    bytes =
      hex_digits
      |> Enum.chunk_every(2)
      |> Enum.map(&Enum.join/1)
      |> Enum.map(& String.to_integer(&1, 16))

    # Convert to a bitstring, which lets us pull out individual bytes really easily
    bits = :binary.list_to_bin(bytes)

    # Parse packet
    {packet, _} = parse_packet(bits)
    packet
  end

  def parse_packet(bits) do
    # Get version and type
    << version :: size(3), type :: size(3), rest :: bitstring >> = bits

    # What kind of packet is this?
    case type do
      # Literal
      4 ->
        {data, rest} = parse_literal_data(rest)
        {
          %LiteralPacket{
            version: version,
            data: data
          },
          rest
        }

      # Operator
      _ ->
        operation = case type do
          0 -> :sum
          1 -> :product
          2 -> :minimum
          3 -> :maximum
          5 -> :greater_than
          6 -> :less_than
          7 -> :equal_to
        end

        << length_type_id :: size(1), rest :: bitstring >> = rest

        if length_type_id == 1 do
          # We have been given the number of sub-packets in this operator packet (11 bits)
          << count :: size(11), rest :: bitstring >> = rest

          {rest, subpackets} = Enum.reduce(1..count, {rest, []}, fn _, {r, packets} ->
            {new_packet, new_rest} = parse_packet(r)
            {new_rest, packets ++ [new_packet]}
          end)

          {
            %OperatorPacket{
              version: version,
              subpackets: subpackets,
              operation: operation,
            },
            rest
          }
        else
          # We have been given the length in bits of all sub-packets in this operator packet (15 bits)
          << bit_count :: size(15), rest :: bitstring >> = rest
          << subpacket_bits :: bits-size(bit_count), rest :: bitstring >> = rest

          subpackets = parse_subpackets_until_empty(subpacket_bits)

          {
            %OperatorPacket{
              version: version,
              subpackets: subpackets,
              operation: operation,
            },
            rest
          }
        end
    end
  end

  def parse_literal_data(<< continue :: size(1), nibble :: size(4), rest :: bitstring >>, n \\ 0) do
    n = (n <<< 4) ||| nibble

    if continue == 1 do
      parse_literal_data(rest, n)
    else
      {n, rest}
    end
  end

  def parse_subpackets_until_empty(<< >>), do: []
  def parse_subpackets_until_empty(rest) do
    {subpacket, rest} = parse_packet(rest)
    [subpacket] ++ parse_subpackets_until_empty(rest)
  end

  def sum_version_numbers(%LiteralPacket{version: v}), do: v
  def sum_version_numbers(%OperatorPacket{version: v, subpackets: subs}) do
    v + (Enum.map(subs, &sum_version_numbers/1) |> Enum.sum)
  end

  def calculate_value(%LiteralPacket{data: data}), do: data
  def calculate_value(%OperatorPacket{operation: op, subpackets: subs}) do
    values = Enum.map(subs, &calculate_value/1)

    case op do
      :sum -> Enum.sum(values)
      :product -> Enum.product(values)
      :minimum -> Enum.min(values)
      :maximum -> Enum.max(values)
      :greater_than ->
        [a, b] = values
        if a > b do 1 else 0 end
      :less_than ->
        [a, b] = values
        if a < b do 1 else 0 end
      :equal_to ->
        [a, b] = values
        if a == b do 1 else 0 end
    end
  end
end

packet = Day16.load_packet

part1 = Day16.sum_version_numbers(packet)
IO.puts("Part 1: #{part1}")

part2 = Day16.calculate_value(packet)
IO.puts("Part 2: #{part2}")
