defmodule ESA.ParseTest do
  use ExUnit.Case

  alias ESA.{Function, Module, Parse, Typespec}

  setup do
    %{
      sample_elixir_file_path: "test/support/data/sample_project/lib/sample_project.ex",
      nested_module_elixir_file_path:
        "test/support/data/sample_project/lib/sample_project/data.ex"
    }
  end

  describe "parse_file/1" do
    test "should properly parse the file", %{sample_elixir_file_path: file_path} do
      {:ok, %Module{} = module} = Parse.parse_file(file_path)

      assert module.name == [:SampleProject]

      assert module.line_number == 1

      assert [
               %Function{} = first_function,
               %Function{} = second_function,
               %Function{} = third_function,
               %Function{} = fourth_function
             ] = module.functions

      assert first_function == %ESA.Function{
               arity: 0,
               line_number: 15,
               name: :hello,
               public: true,
               typespec: Typespec.none()
             }

      assert second_function == %ESA.Function{
               arity: 2,
               line_number: 20,
               name: :this_function_has_a_typespec,
               public: true,
               typespec: Typespec.none()
             }

      assert third_function == %ESA.Function{
               arity: 2,
               line_number: 24,
               name: :this_function_does_not_have_a_typespec,
               public: true,
               typespec: Typespec.none()
             }

      assert fourth_function == %ESA.Function{
               arity: 2,
               line_number: 28,
               name: :private_function,
               public: false,
               typespec: Typespec.none()
             }
    end

    test "should handle nested module names", %{nested_module_elixir_file_path: file_path} do
      {:ok, %Module{} = module} = Parse.parse_file(file_path)
      assert module.name == [:SampleProject, :Data]
    end
  end
end
