defmodule ESA.ParseTest do
  use ExUnit.Case

  alias ESA.{Function, Module, Parse, Typespec}

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
          def add(x, y) when is_number(x) and is_number(y) do
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
  end

  # describe "parse_file/1" do
  #  test "should properly parse the file", %{sample_elixir_file_path: file_path} do
  #    {:ok, %Module{} = module} = Parse.parse_file(file_path)

  #    assert module.name == [:SampleProject]

  #    assert module.line_number == 1

  #    assert [
  #             %Function{} = first_function,
  #             %Function{} = second_function,
  #             %Function{} = third_function,
  #             %Function{} = fourth_function
  #           ] = module.functions

  #    assert first_function == %ESA.Function{
  #             argument_names: [],
  #             line_number: 15,
  #             name: :hello,
  #             public: true,
  #             typespec: Typespec.none()
  #           }

  #    assert second_function == %ESA.Function{
  #             argument_names: [:x, :y],
  #             line_number: 20,
  #             name: :this_function_has_a_typespec,
  #             public: true,
  #             typespec: Typespec.none()
  #           }

  #    assert third_function == %ESA.Function{
  #             argument_names: [:x, :y],
  #             line_number: 24,
  #             name: :this_function_does_not_have_a_typespec,
  #             public: true,
  #             typespec: Typespec.none()
  #           }

  #    assert fourth_function == %ESA.Function{
  #             argument_names: [:apple, :banana],
  #             line_number: 28,
  #             name: :private_function,
  #             public: false,
  #             typespec: Typespec.none()
  #           }
  #  end

  #  test "should handle nested module names", %{nested_module_elixir_file_path: file_path} do
  #    {:ok, %Module{} = module} = Parse.parse_file(file_path)
  #    assert module.name == [:SampleProject, :Data]
  #  end
  # end
end
