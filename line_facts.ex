defmodule LineFacts do
  @moduledoc "Get some facts about the lines of your files"

  @doc "Here you will find the length of all your lines"
  def line_lengths!(path) do
    path
    |> filter_lines!()
    |> Enum.map(&String.length/1)
  end

  @doc "Here are all the lines that are longer than 80 characters!"
  def large_lines!(path) do
    path
    |> filter_lines!()
    |> Enum.filter(&(String.length(&1) > 80))
  end

  @doc "Returns the length of the files longest line"
  def longest_line_length!(path) do
    path
    |> filter_lines!()
    |> Stream.map(&String.length/1)
    |> Enum.max()
  end

  @doc "Returns the longest line in the file"
  def longest_line!(path) do
    path
    |> filter_lines!()
    |> Enum.max_by(&String.length/1)
  end

  @doc "Lists the word count of each line in a file"
  def words_per_line!(path) do
    path
    |> filter_lines!()
    |> Enum.map(&word_count!/1)
  end

  defp word_count!(line) do
    line
    |> String.split()
    |> length()
  end

  defp filter_lines!(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end
end
