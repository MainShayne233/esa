defmodule ESA.Parse do
  @moduledoc """
  Functions for parsing Elixir code.
  """

  alias ESA.Module
  alias ESA.Function
  alias ESA.Util.EnumUtil

  @type quoted_module :: any()

  @function_headers [:def, :defp]

  defguardp is_function_header(possible_function_header)
            when possible_function_header in @function_headers

  @doc """
  Takes a string version of a module and returns a Module.t()
  """
  @spec module_from_string(string_module :: String.t(), file_name :: String.t()) ::
          {:ok, Module.t()} | {:error, atom()}
  def module_from_string(string_module, file_name)
      when is_binary(string_module) and is_binary(file_name) do
    with {:ok, quoted_module} <- Code.string_to_quoted(string_module) do
      module_from_quoted(quoted_module, file_name)
    end
  end

  @doc """
  Takes a quoted module and returns a Module.t()
  """
  @spec module_from_quoted(quoted_module(), String.t()) :: {:ok, Module.t()} | {:error, atom()}
  def module_from_quoted(
        {:defmodule, [line: line_number],
         [{:__aliases__, [line: line_number], module_name}, [do: {:__block__, [], body}]]},
        file_name
      ) do
    %Module{name: module_name, line_number: 1, file_name: file_name}
    |> process_body(body)
  end

  defp process_body(module, []) do
    %Module{module | functions: Enum.reverse(module.functions)}
    |> return()
  end

  defp process_body(module, [entry | rest]) do
    case process_entry(entry) do
      {:ok, %Function{} = function} ->
        %Module{module | functions: [function | module.functions]}
        |> process_body(rest)

      :ignore ->
        process_body(module, rest)
    end
  end

  @spec process_entry(any()) :: {:ok, Function.t()} | :ignore
  defp process_entry({function_header, [line: line_number], function_contents})
       when is_function_header(function_header) do
    %Function{
      line_number: line_number,
      public: function_header == :def
    }
    |> process_function_contents(function_contents)
  end

  defp process_entry(_unsupported_entry) do
    :ignore
  end

  @spec process_function_contents(Function.t(), list()) :: {:ok, Function.t()} | {:error, atom()}
  defp process_function_contents(%Function{} = function, []), do: {:ok, function}

  defp process_function_contents(%Function{} = function, [function_content | rest]) do
    with {:ok, %Function{} = updated_function} <-
           process_function_content(function, function_content) do
      process_function_contents(updated_function, rest)
    end
  end

  @spec process_function_content(Function.t(), any()) :: {:ok, Function.t()} | {:error, atom()}
  defp process_function_content(
         %Function{} = function,
         {:when, [line: 4], function_arguments_content}
       ) do
    process_function_arguments_content(function, function_arguments_content)
  end

  defp process_function_content(
    %Function{} = function,
    [do: _function_body]
  ) do
    {:ok, function}
  end

  @spec process_function_arguments_content(Function.t(), list()) ::
          {:ok, Function.t()} | {:error, atom()}
  defp process_function_arguments_content(%Function{} = function, [
         {function_name, [line: line_number], arguments_contents} | _guard_clauses
       ]) do
    %Function{function | name: function_name}
    |> process_arguments_contents(arguments_contents)
  end

  @spec process_arguments_contents(Function.t(), list()) :: {:ok, Function.t()} | {:error, atom()}
  defp process_arguments_contents(%Function{} = function, []) do
    {:ok, %Function{function |
        arguments: Enum.reverse(function.arguments)
     }}
  end

  defp process_arguments_contents(%Function{} = function, [argument_content | rest]) do
    with {:ok, %Function{} = updated_function} <-
           process_arguments_content(function, argument_content) do
      process_arguments_contents(updated_function, rest)
    end
  end

  @spec process_arguments_content(Function.t(), any()) :: {:ok, Function.t()} | {:error, atom()}
  defp process_arguments_content(%Function{} = function, {:\\, _line_number, [{argument_name, _line_number, _}, _default_arg]}) do
    %Function{function | arguments: [argument_name | function.arguments]}
    |> return()
  end

  defp process_arguments_content(%Function{} = function, {argument_name, _line_number, _}) do
    %Function{function | arguments: [argument_name | function.arguments]}
    |> return()
  end

#  defp process_arguments_content(%Function{} = function, argument_content) do
#    IO.inspect(argument_content)
#  end

  @spec return(any()) :: {:ok, any()}
  defp return(value), do: {:ok, value}
end
