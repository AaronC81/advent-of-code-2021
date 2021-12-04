Code.require_file("lib/aoc_utils.exs")

defmodule Day4 do
  def load_game() do
    # Split into the first line and rest of lines - the first line is the list of numbers to call,
    # and the rest are the boards
    [calls | board_lines] = AOC.read_input("day4") |> String.split("\n")

    # Convert calls from "1,2,3" form to list of integers
    calls =
      String.split(calls, ",")
      |> Enum.map(&String.to_integer/1)

    boards =
      # Get boards in chunks of 6 (one blank line, five lines with numbers)
      Enum.chunk_every(board_lines, 6)
      # Discard that first blank line from each board
      |> Enum.map(&Enum.drop(&1, 1))
      # Split each inner row into an array of integers and "filled" booleans
      |> Enum.map(fn board -> Enum.map(board, fn line ->
        String.split(line) |> Enum.map(&String.to_integer/1) |> Enum.map(fn i -> {i, false} end)
      end) end)

    {calls, boards}
  end

  @doc "Fills in a number on a board, if it is present."
  def call_for_board(board, number) do
    Enum.map(board, fn row ->
      Enum.map(row, fn cell ->
        # If this is the called number, set it to true
        {cell_number, _} = cell
        if cell_number == number do
          {cell_number, true}
        else
          cell
        end
      end)
    end)
  end

  @doc "Fills in a number on all boards."
  def call_for_boards(boards, number) do
    Enum.map(boards, &call_for_board(&1, number))
  end

  @doc "Transposes (i.e. 'rotates') a 2D array."
  # From: https://stackoverflow.com/a/42887944/2626000
  def transpose(rows) do
    rows
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end

  @doc "Returns true if a board has a full row or column of called numbers."
  def winning_board?(board) do
    # Check if there's a winning row
    winning_row =
      Enum.any?(board, fn row ->
        # Convert e.g. [{1, true}, {2, false}] into just [true, false], then check if all true
        Enum.map(row, &elem(&1, 1)) |> Enum.all?
      end)

    # Check if there's a winning column
    winning_col =
      Enum.any?(transpose(board), fn row ->
        # Convert e.g. [{1, true}, {2, false}] into just [true, false], then check if all true
        Enum.map(row, &elem(&1, 1)) |> Enum.all?
      end)

    winning_row || winning_col
  end

  @doc "Finds the first winning board for a list of calls, returning the board and the last call."
  def find_first_winning_board_and_call(boards, calls) do
    # Call number
    [next_call | rest_calls] = calls
    called_boards = call_for_boards(boards, next_call)

    # Have any boards now won?
    winning_board = Enum.find(called_boards, nil, &winning_board?/1)
    if winning_board != nil do
      # Yes, return it and the number which made it win
      {winning_board, next_call}
    else
      # No, recurse
      find_first_winning_board_and_call(called_boards, rest_calls)
    end
  end

  @doc "Finds the worst winning board for a list of calls, returning the board and the last call."
  def find_last_winning_board_and_call(boards, [next_call | rest_calls]) do
    # Call number
    called_boards = call_for_boards(boards, next_call)

    # Find new boards which won this round
    {new_winners, yet_to_win} = Enum.split_with(called_boards, &winning_board?/1)
    if length(yet_to_win) == 0 do
      # This was the last to win! Return it
      {Enum.at(new_winners, 0), next_call}
    else
      # There'll still be a later board to win, recurse
      find_last_winning_board_and_call(yet_to_win, rest_calls)
    end
  end

  @doc "Sums the unmarked numbers of a board"
  def sum_unmarked(board) do
    Enum.map(board, fn row ->
      Enum.filter(row, &(!elem(&1, 1)))
      |> Enum.map(&elem(&1, 0))
      |> Enum.sum()
    end) |> Enum.sum()
  end
end

{calls, boards} = Day4.load_game()

{winning_board, winning_call} = Day4.find_first_winning_board_and_call(boards, calls)
part_1 = Day4.sum_unmarked(winning_board) * winning_call
IO.puts("Part 1: #{part_1}")

{winning_board, winning_call} = Day4.find_last_winning_board_and_call(boards, calls)
part_1 = Day4.sum_unmarked(winning_board) * winning_call
IO.puts("Part 2: #{part_1}")
