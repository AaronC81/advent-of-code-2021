defmodule AOC do
  @spec read_input(String.t()) :: binary
  def read_input(name) do
    Path.join([__DIR__, "..", "input", name])
    |> File.read!()
  end
end
