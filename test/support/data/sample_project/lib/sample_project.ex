defmodule SampleProject do
  @moduledoc """
  Documentation for SampleProject.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SampleProject.hello()
      :world

  """
  def hello do
    :world
  end

  @spec this_function_has_a_typespec(number(), number()) :: number()
  def this_function_has_a_typespec(x, y) do
    x + y
  end

  def this_function_does_not_have_a_typespec(x, y) do
    x + y
  end

  defp private_function(apple, banana) do
    apple ++ banana
  end
end
