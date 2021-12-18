Code.require_file("lib/aoc_utils.exs")

# This solution mainly works through the `BinaryPath` module, which introduces a data structure
# working like a cursor through the deeply nested pairs.
#
# `BinaryPath` isn't its own struct, it works on an array of either :left or :right symbols
# describing the movements to be taken through the pairs to reach the current item.
#
# For example, on the number {1, {{2, 3}, 4}}, the path [:right, :left, :right] would point to 3.
#
# The power here comes from the fact that you can advance the path forwards; calling `advance` on
# the path above would move it to point to 4 instead. This will work regardless of the layers of
# nesting which must be entered or exited to reach the next item!
#
# You can't move backwards, but this problem only requires you to ever know the item one behind the
# previous one (for adding the left side of an exploded pair to), so we just keep track of both the
# current and previous paths in any methods which need it.

defmodule Day18 do
  defmodule BinaryPath do
    @doc "Follow the path to extract an item from the container."
    def get(container, path)
    def get({left, _}, [:left | rest]), do: get(left, rest)
    def get({_, right}, [:right | rest]), do: get(right, rest)
    def get(container, []), do: container
    def get(something, _), do: raise "cannot navigate into #{inspect(something)}"

    @doc "Follow the path to replace an item within the container with a new item."
    def put(container, path, item)
    def put({left, right}, [:left | rest], item), do: {put(left, rest, item), right}
    def put({left, right}, [:right | rest], item), do: {left, put(right, rest, item)}
    def put(_, [], item), do: item
    def put(something, _), do: raise "cannot navigate into #{inspect(something)}"

    @doc "Moves the path rightwards within the container (viewing the container as a list)."
    def advance(container, path, allow_item \\ false) do
      # Determine whether we can move into the item the path currently points to
      case get(container, path) do
        # Yep! Move into its left side
        {_, _} -> hone(container, path ++ [:left])

        # Horrendous special case after moving right out of something
        _ when allow_item -> path

        # Nope...
        _ ->
          last = Enum.at(path, -1)
          case last do
            # If we're on the left, we can step out and move to the right
            :left ->
              rest = Enum.drop(path, -1)
              hone(container, rest ++ [:right])

            # Otherwise all rights plus one left, add a right, and recurse
            :right ->
              rest =
                path
                |> Enum.reverse
                |> Enum.drop_while(& &1 == :right)

              # If empty after dropping all rights, we're done
              if length(rest) == 0 do
                nil
              else
                rest =
                  rest
                  |> Enum.drop(1)
                  |> Enum.reverse

                advance(container, rest ++ [:right], true)
              end
          end
      end
    end

    @doc "Moves into the left of the given path repeatedly until it hits an end node."
    def hone(container, path) do
      case get(container, path) do
        {_, _} -> hone(container, path ++ [:left])
        _ -> path
      end
    end

    @doc "Creates a new path pointing to the root item of a container."
    def new() do
      []
    end
  end

  def load_numbers() do
    # Yes, this is awful, but I've spent WAY too long on the logic of reduction today to care
    AOC.read_input("day18")
    |> String.replace("[", "{")
    |> String.replace("]", "}")
    |> String.split("\n")
    |> Enum.map(fn line ->
      {result, []} = Code.eval_string(line)
      result
    end)
  end

  def explode(number, path, previous_path \\ nil)

  # We got through the entire number without exploding anything
  def explode(number, nil, _), do: {:ok, number}

  # We need to explode at this path!
  def explode(number, path, previous_path) when length(path) > 4 do
    # Assert we're on the left of the path
    if Enum.at(path, -1) != :left do
      raise "expected explosion to happen on left of path"
    end

    # Get the thing to explode - it should be a pair with two regular numbers
    path_to_exploding_pair = Enum.drop(path, -1)
    {left, right} = BinaryPath.get(number, path_to_exploding_pair)
    if !is_integer(left) || !is_integer(right) do
      raise "expected to explode pair of two regular numbers"
    end

    # The number at the previous path, if any, has the left number added to it
    number =
      if previous_path != nil && length(previous_path) != 0 do
        BinaryPath.put(number, previous_path, BinaryPath.get(number, previous_path) + left)
      else
        number
      end

    # The number at the next path, if any, has the right number added to it
    # Advance TWICE, so we go past the right of this same pair
    next_path = BinaryPath.advance(number, BinaryPath.advance(number, path))
    number =
      if next_path != nil do
        BinaryPath.put(number, next_path, BinaryPath.get(number, next_path) + right)
      else
        number
      end

    # Replace pair with a 0
    number = BinaryPath.put(number, path_to_exploding_pair, 0)

    # Stop here, since we've made a reduction
    {:exploded, number}
  end

  # No need to explode yet, keep recursing
  def explode(number, path, _), do: explode(number, BinaryPath.advance(number, path), path)

  def split(number, nil), do: {:ok, number}
  def split(number, path) do
    here = BinaryPath.get(number, path)
    if is_integer(here) && here >= 10 do
      left = div(here, 2)
      right = left + rem(here, 2)

      new_number = BinaryPath.put(number, path, {left, right})
      {:split, new_number}
    else
      split(number, BinaryPath.advance(number, path))
    end
  end

  def reduce(number) do
    case explode(number, []) do
      {:exploded, new_number} -> reduce(new_number)
      {:ok, _} ->
        case split(number, []) do
          {:split, new_number} -> reduce(new_number)
          {:ok, _} -> number
        end
    end
  end

  def add(left, right) do
    reduce({left, right})
  end

  def add_all(numbers) do
    Enum.reduce(numbers, fn right, left -> add(left, right) end)
  end

  def magnitude(number) when is_integer(number), do: number
  def magnitude({left, right}), do: 3 * magnitude(left) + 2 * magnitude(right)
end

numbers = Day18.load_numbers

part1 = Day18.magnitude(Day18.add_all(numbers))
IO.puts("Part 1: #{part1}")

part2 =
  Enum.flat_map(numbers, fn left ->
    Enum.map(numbers, fn right ->
      Day18.magnitude(Day18.add(left, right))
    end)
  end)
  |> Enum.max
IO.puts("Part 2: #{part2}")
