defmodule ESA.ParseTest do
  use ExUnit.Case

  alias ESA.{Function, Module, Parse}

  setup do
    module_string =
      quote do
        defmodule Math do
          @moduledoc """
          Doing math stuff.
          """

          @doc """
          Adds two numbers together.
          """
          def add(x, y \\ 1) when is_number(x) and is_number(y) do
            x + y
          end
        end
      end
      |> Macro.to_string()

    %{
      module_string: module_string,
      file_name: "lib/math.ex"
    }
  end

  describe "module_from_string/1" do
    test "should return a valid module struct for a valid module string", %{
      module_string: module_string,
      file_name: file_name
    } do
      assert {:ok, %Module{} = module} = Parse.module_from_string(module_string, file_name)

      assert module.name == [:Math]

      assert module.line_number == 1

      assert module.file_name == file_name

      assert is_list(module.functions)

      assert is_list(module.typespecs)
    end

    test "should properly parse public functions that are @doc'd and @spec'd, guard clause'd, and have default args",
         %{
           module_string: module_string,
           file_name: file_name
         } do
      assert {:ok, %Module{functions: [%Function{} = first_function | _]}} =
               Parse.module_from_string(module_string, file_name)

      assert first_function.name == :add
      assert first_function.public == true
      assert [:x, :y] = first_function.arguments
      assert first_function.line_number == 4
    end
  end
end
