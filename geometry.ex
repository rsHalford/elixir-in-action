defmodule Geometry do
  @moduledoc "Implements the basic shape fuctions"
  @pi 3.14159

  @doc "Computes the area of a given shape"
  def area({:rectangle, a, b}) do
    a * b
  end

  def area({:square, l}) do
    l * l
  end

  def area({:circle, r}) do
    r * r * @pi
  end

  def area(unknown) do
    {:error, {:unknown_argument, unknown}}
  end
end

defmodule GeometryOld do
  def rectangle_area(a, b) do
    a * b
  end

  def square_area(a) do
    rectangle_area(a, a)
  end
end

defmodule Rectangle do
  def area(a), do: area(a, a)
  def area(a, b), do: a * b
end

defmodule Rhomboid do
  @doc "Computes the area of a rhomboid from a tuple"
  @spec area(number) :: number
  def area({a, b}) do
    a * b
  end
end

defmodule Circle do
  @moduledoc "Implements basic circle functions"
  @pi 3.14159

  @doc "Computes the area of a circle"
  @spec area(number) :: number
  def area(r), do: r * r * @pi

  @doc "Computes the circumference of a circle"
  @spec circumference(number) :: number
  def circumference(r), do: 2 * r * @pi
end
