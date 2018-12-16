defmodule ESA.Parse do
  @moduledoc """
  Functions for parsing Elixir code.
  """

  alias ESA.Module
  alias ESA.Function

  @type raw_module :: {:defmodule, keyword(), list()}

  @function_headers [:def, :defp]

  @doc """
  Should return a parsed module for the given file.
  """
  @spec parse_file(file_path :: String.t()) :: {:ok, Module.t()} | {:error, atom()}
  def parse_file(file_path) when is_binary(file_path) do
    with {:ok, file} <- File.read(file_path),
         {:ok, raw_module} <- Code.string_to_quoted(file) do
      parse_raw_module(raw_module)
    end
  end

  @doc """
  Should parse the raw tuple module
  """
  @spec parse_raw_module(raw_module()) :: {:ok, Module.t()} | {:error, atom()}
  def parse_raw_module(
        {:defmodule, [line: line_number],
         [{:__aliases__, [line: line_number], module_name}, [do: {:__block__, [], body}]]}
      ) do
    %Module{name: module_name, line_number: 1}
    |> process_body(body)
  end

  @spec return(any()) :: {:ok, any()}
  defp return(value), do: {:ok, value}

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

  defguardp is_function_header(possible_function_header)
            when possible_function_header in @function_headers

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
end
