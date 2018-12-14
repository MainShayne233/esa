defmodule ESA.Typespec do
  @moduledoc """
  Defines a struct representing an Elixir typespec.
  """

  use TypedStruct

  @typedoc """
  A struct representing an Elixir typespec.
  """

  @type return_type :: atom()

  @none :__TYPESPEC__NONE__

  typedstruct do
    field(:name, atom(), enforce: true)
    field(:arity, integer(), enforce: true)
    field(:return_type, return_type(), enforce: true)
  end

  def none, do: @none
end
