defmodule Marcli.Formatter do
  @moduledoc """
  Makeup formatter that produces ANSI-escaped terminal output.

  Maps Makeup token types (`:keyword`, `:string`, `:comment`, etc.) to ANSI
  escape sequences using a configurable style map from `Marcli.Theme`.

  ## Standalone usage with Makeup

      theme = Marcli.Theme.default()

      Makeup.highlight(source,
        lexer: "elixir",
        formatter: Marcli.Formatter,
        formatter_options: [syntax: theme.syntax, reset: theme.reset]
      )

  ## Token type fallback

  When a specific token type (e.g. `:keyword_constant`) is not present in
  the style map, the formatter walks up the hierarchy by stripping trailing
  segments: `:keyword_constant` -> `:keyword` -> unstyled.
  """

  alias Marcli.Theme

  @type token :: {atom(), map(), iodata()}

  @doc """
  Formats a list of Makeup tokens as an ANSI-escaped binary string.

  ## Options

  - `:syntax` -- map of token types to ANSI escape sequences
    (default: `Marcli.Theme.default().syntax`)
  - `:reset` -- ANSI reset sequence (default: `"\\e[0m"`)
  """
  @spec format_as_binary([token()], keyword()) :: String.t()
  def format_as_binary(tokens, opts \\ []) do
    tokens
    |> format_as_iolist(opts)
    |> IO.iodata_to_binary()
  end

  @doc """
  Formats a list of Makeup tokens as an iolist with ANSI escape sequences.

  Accepts the same options as `format_as_binary/2`.
  """
  @spec format_as_iolist([token()], keyword()) :: iolist()
  def format_as_iolist(tokens, opts \\ []) do
    {syntax, reset} = extract_opts(opts)
    Enum.map(tokens, &format_token(&1, syntax, reset))
  end

  @doc """
  Same as `format_as_binary/2` (no wrapping needed for terminal output).
  """
  @spec format_inner_as_binary([token()], keyword()) :: String.t()
  def format_inner_as_binary(tokens, opts \\ []), do: format_as_binary(tokens, opts)

  @doc """
  Same as `format_as_iolist/2` (no wrapping needed for terminal output).
  """
  @spec format_inner_as_iolist([token()], keyword()) :: iolist()
  def format_inner_as_iolist(tokens, opts \\ []), do: format_as_iolist(tokens, opts)

  @doc """
  Formats a single Makeup token `{tag, meta, value}` into a string.

  Looks up the ANSI sequence for `tag` in `syntax`, falling back through
  parent types. Handles newlines within token values by resetting and
  re-opening the style at each line boundary.
  """
  @spec format_token(token(), map(), String.t()) :: String.t()
  def format_token({tag, _meta, value}, syntax, reset) do
    text = iodata_to_binary(value)

    case lookup_style(syntax, tag) do
      style when style in [nil, ""] ->
        text

      ansi ->
        text
        |> String.split("\n")
        |> Enum.map_join("\n", fn
          "" -> ""
          segment -> ansi <> segment <> reset
        end)
    end
  end

  # Walk up the token type hierarchy:
  #   :keyword_constant -> :keyword -> nil
  #   :name_builtin_pseudo -> :name_builtin -> :name -> nil
  defp lookup_style(syntax, type) do
    case Map.get(syntax, type) do
      nil ->
        case parent_type(type) do
          nil -> nil
          parent -> lookup_style(syntax, parent)
        end

      ansi ->
        ansi
    end
  end

  defp parent_type(type) do
    parts = type |> Atom.to_string() |> String.split("_")

    if length(parts) > 1 do
      parts |> Enum.drop(-1) |> Enum.join("_") |> String.to_existing_atom()
    end
  rescue
    ArgumentError -> nil
  end

  defp extract_opts(opts) do
    theme = Theme.default()
    syntax = Keyword.get(opts, :syntax, theme.syntax)
    reset = Keyword.get(opts, :reset, theme.reset)
    {syntax, reset}
  end

  defp iodata_to_binary(data) when is_binary(data), do: data
  defp iodata_to_binary(data) when is_list(data), do: IO.iodata_to_binary(data)
  defp iodata_to_binary(data) when is_integer(data), do: <<data::utf8>>
end
