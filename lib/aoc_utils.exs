defmodule AOC do
  @spec read_input(String.t()) :: binary
  def read_input(name) do
    Path.join([Path.dirname(__ENV__.file), "..", "input", name])
    |> File.read!()
  end
end
