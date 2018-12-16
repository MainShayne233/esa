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
    field(:name, atom(), enforce: true)
    field(:argument_names, [atom()], default: [])
    field(:public, boolean(), enforce: true)
    field(:typespec, Typespec.maybe_typespec(), default: Typespec.none())
    field(:line_number, integer(), enforce: true)
  end
end
