defmodule ESA.Function do
  @moduledoc """
  Defines a struct representing an Elixir function.
  """

  use TypedStruct

  alias ESA.Typespec

  @typedoc """
  A struct representing an Elixir function.
  """

  typedstruct do
    field(:name, atom())
    field(:arguments, [atom()], default: [])
    field(:public, boolean())
    field(:line_number, integer())
  end
end
