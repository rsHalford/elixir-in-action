defmodule NaturalNums do
  def print(1), do: IO.puts(1)

  def print(n) do
    IO.puts(n)
    print(n - 1)
  end
end

# Tail-Recursive ListHelper
defmodule ListHelper do
  @doc "Totals the integers in a list"
  def sum(list) do
    do_sum(list, 0)
  end

  defp do_sum([], current_sum) do
    current_sum
  end

  defp do_sum([head | tail], current_sum) do
    do_sum(tail, current_sum + head)
  end

  @doc "Calculates the length of a list"
  def list_len(list) do
    get_len(list, 0)
  end

  defp get_len([], len) do
    len
  end

  defp get_len([_ | tail], len) do
    get_len(tail, len + 1)
  end

  @doc "Returns a list of all integers in a given range"
  def range(from, to) do
    calc_range(from, to, [])
  end

  defp calc_range(from, to, list) when from > to do
    list
  end

  defp calc_range(from, to, list) do
    calc_range(from, to - 1, [to | list])
  end

  @doc "Take a list and return a list of the positives"
  def positive(list) do
    is_positive(list, [])
  end

  defp is_positive([], list) do
    Enum.reverse(list)
  end

  defp is_positive([head | tail], list) when head > 0 do
    is_positive(tail, [head | list])
  end

  defp is_positive([_ | tail], list) do
    is_positive(tail, list)
  end
end
