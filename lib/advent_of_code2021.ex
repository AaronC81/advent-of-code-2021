defmodule AdventOfCode2021 do
  def start(_type, _args) do
    # Nothing needs to be done here
    IO.puts "Run the code for an individual day using: mix run lib/dayX.exs"

    # Elixir app must return a "supervision tree" when run - just return a blank one
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
