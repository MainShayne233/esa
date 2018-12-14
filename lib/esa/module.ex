defmodule ESA.Module do
  @moduledoc """
  Defines a struct representing an Elixir module.
  """

  use TypedStruct

  alias ESA.Function
  alias ESA.Typespec

  @typedoc """
  A struct representing an Elixir module.
  """

  typedstruct do
    field(:name, atom(), enforce: true)
    field(:functions, [Function.t()], default: [])
    field(:typespecs, [Typespec.t()], default: [])
    field(:line_number, integer(), enforce: true)
  end
end
