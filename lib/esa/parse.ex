defmodule ESA.Parse do
  @moduledoc """
  Functions for parsing Elixir code.
  """

  alias ESA.Module
  alias ESA.Function

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
  defp process_entry(
         {function_header, [line: line_number],
          [
            {function_name, [line: line_number], arguments},
            [do: _body]
          ]}
       )
       when is_function_header(function_header) do
    %Function{
      name: function_name,
      argument_names: parse_argument_names(arguments),
      public: [def: true, defp: false][function_header],
      line_number: line_number
    }
    |> return()
  end

  defp process_entry(_unsupported_entry) do
    :ignore
  end

  @spec parse_argument_names(list) :: [atom()]
  defp parse_argument_names(list) when is_list(list) do
    Enum.map(list, fn
      {name, _, nil} ->
        name

      name ->
        name
    end)
  end

  defp parse_argument_names(nil) do
    []
  end

  @spec return(any()) :: {:ok, any()}
  defp return(value), do: {:ok, value}
end
