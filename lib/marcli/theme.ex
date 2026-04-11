defmodule Marcli.Theme do
  @moduledoc """
  Theme configuration for terminal Markdown rendering.

  Every visual aspect of the rendered output is controlled by fields
  in this struct: ANSI escape sequences, marker characters, glyphs,
  box-drawing characters, and sizing.

  ## Color values

  All fields that accept ANSI escape sequences (headings, inline
  styles, code blocks, etc.) can be given in two forms:

  * **Binary** -- a raw ANSI escape string such as `"\\e[1;33m"`,
    exactly as before.

  * **`{Color.input(), keyword()}`** -- a tuple where the first
    element is anything `Color.new/1` accepts (a hex string like
    `"#ff9900"`, a CSS named colour like `"red"`, an atom like
    `:rebeccapurple`, or a `Color.*` struct) and the second element
    is an options keyword passed to `Color.ANSI.to_string/2`.
    Supported options are `:mode` (`:truecolor`, `:ansi256`,
    `:ansi16`) and `:layer` (`:foreground`, `:background`).

  The tuple form is resolved eagerly when the theme is constructed
  via `merge/1` or `load/1`, so there is no runtime overhead.

  Requires the optional `:color` dependency:

      {:color, "~> 0.3", optional: true}

  ### Examples

      Marcli.Theme.merge(h1: {"#ff9900", mode: :truecolor})
      Marcli.Theme.merge(h1: {"red", mode: :ansi256})
      Marcli.Theme.merge(h1: {"red", mode: :ansi16, layer: :foreground})

  ## Loading from file

      theme = Marcli.Theme.load(".marcli.exs")
      Marcli.render(markdown, theme: theme)

  The file must evaluate to a keyword list whose keys match struct
  fields. Unknown keys are silently ignored.

  ## Defaults

  Calling `Marcli.Theme.default()` returns the built-in theme that
  matches the hardcoded rendering from Marcli v0.1.
  """

  @reset "\e[0m"

  # credo:disable-for-lines:60
  @default_syntax %{
    # Comments
    comment: "\e[3;90m",
    # Errors
    error: "\e[1;31m",
    # Keywords
    keyword: "\e[35m",
    keyword_constant: "\e[36m",
    keyword_declaration: "\e[35m",
    keyword_namespace: "\e[35m",
    keyword_pseudo: "\e[35m",
    keyword_reserved: "\e[35m",
    keyword_type: "\e[36m",
    # Names
    name_attribute: "\e[33m",
    name_builtin: "\e[36m",
    name_builtin_pseudo: "\e[36m",
    name_class: "\e[1;36m",
    name_constant: "\e[1;33m",
    name_decorator: "\e[33m",
    name_entity: "\e[1;33m",
    name_exception: "\e[1;31m",
    name_function: "\e[33m",
    name_function_magic: "\e[33m",
    name_label: "\e[36m",
    name_namespace: "\e[1;36m",
    name_tag: "\e[1;35m",
    name_variable: "\e[37m",
    # Strings
    string: "\e[32m",
    string_char: "\e[32m",
    string_delimiter: "\e[32m",
    string_doc: "\e[3;32m",
    string_escape: "\e[1;32m",
    string_interpol: "\e[1;32m",
    string_regex: "\e[31m",
    string_sigil: "\e[32m",
    string_symbol: "\e[36m",
    # Numbers
    number: "\e[34m",
    # Operators
    operator: "",
    operator_word: "\e[35m",
    # Punctuation
    punctuation: "",
    # Generic
    generic_deleted: "\e[31m",
    generic_emph: "\e[3m",
    generic_error: "\e[31m",
    generic_heading: "\e[1m",
    generic_inserted: "\e[32m",
    generic_output: "\e[90m",
    generic_prompt: "\e[1m",
    generic_strong: "\e[1m",
    generic_subheading: "\e[1;35m",
    generic_traceback: "\e[31m"
  }

  defstruct reset: @reset,

            # Headings
            h1: "\e[1;33m",
            h2: "\e[1;36m",
            h3: "\e[1;37m",

            # Inline styles
            bold: "\e[1m",
            italic: "\e[3m",
            strikethrough: "\e[9m",
            inline_code: "\e[32m",

            # Links
            link_text: "\e[4m\e[34m",
            link_url: "\e[2m",

            # Images
            image_text: "\e[2m",
            image_prefix: "[image: ",
            image_suffix: "]",
            image_url: "\e[2m",

            # Code blocks
            code_border: "\e[2m",
            code_text: "\e[32m",
            code_top: "  \u250c\u2500",
            code_left: "  \u2502 ",
            code_bottom: "  \u2514\u2500",

            # Block quotes
            block_quote: "\e[2m",
            block_quote_prefix: "  \u2502 ",

            # Bullet lists
            bullet_marker: "  \u25b8 ",
            task_checked: "  \u2611 ",
            task_unchecked: "  \u2610 ",

            # Ordered lists
            ordered_indent: "  ",
            ordered_glyphs:
              ~w(\u2460 \u2461 \u2462 \u2463 \u2464 \u2465 \u2466 \u2467 \u2468 \u2469 \u246a \u246b \u246c \u246d \u246e \u246f \u2470 \u2471 \u2472 \u2473),

            # List continuation indent (for loose list items)
            list_continuation: "    ",

            # Thematic breaks
            thematic_break: "\e[2m",
            thematic_break_char: "\u2500",
            thematic_break_width: 40,

            # HTML blocks
            html_block: "\e[2m",

            # Tables
            table_border: "\e[2m",
            table_header: "\e[1m",
            table_chars: %{
              tl: "\u250c",
              tr: "\u2510",
              bl: "\u2514",
              br: "\u2518",
              h: "\u2500",
              v: "\u2502",
              tm: "\u252c",
              bm: "\u2534",
              lm: "\u251c",
              rm: "\u2524",
              x: "\u253c"
            },

            # Syntax highlighting (Makeup integration)
            syntax_highlight: true,
            syntax: @default_syntax

  @typedoc """
  A colour value accepted by theme fields.

  Either a ready-made ANSI escape binary **or** a
  `{Color.input(), keyword()}` tuple that will be resolved via
  `Color.ANSI.to_string/2` at theme construction time.
  """
  @type color_input :: String.t() | {term(), keyword()}

  @type t :: %__MODULE__{
          reset: String.t(),
          h1: String.t(),
          h2: String.t(),
          h3: String.t(),
          bold: String.t(),
          italic: String.t(),
          strikethrough: String.t(),
          inline_code: String.t(),
          link_text: String.t(),
          link_url: String.t(),
          image_text: String.t(),
          image_prefix: String.t(),
          image_suffix: String.t(),
          image_url: String.t(),
          code_border: String.t(),
          code_text: String.t(),
          code_top: String.t(),
          code_left: String.t(),
          code_bottom: String.t(),
          block_quote: String.t(),
          block_quote_prefix: String.t(),
          bullet_marker: String.t(),
          task_checked: String.t(),
          task_unchecked: String.t(),
          ordered_indent: String.t(),
          ordered_glyphs: [String.t()],
          list_continuation: String.t(),
          thematic_break: String.t(),
          thematic_break_char: String.t(),
          thematic_break_width: non_neg_integer(),
          html_block: String.t(),
          table_border: String.t(),
          table_header: String.t(),
          table_chars: %{atom() => String.t()},
          syntax_highlight: boolean(),
          syntax: %{atom() => String.t()}
        }

  @doc "Returns the built-in default theme."
  @spec default :: t()
  def default, do: %__MODULE__{}

  @doc """
  Loads a theme from the given file path.

  The file must evaluate to a keyword list. Keys that match struct
  fields override the defaults; unknown keys are ignored.

  Returns `default()` when the file does not exist.
  """
  @spec load(Path.t()) :: t()
  def load(path \\ ".marcli.exs") do
    if File.exists?(path) do
      {overrides, _bindings} = Code.eval_file(path)
      merge(overrides)
    else
      default()
    end
  end

  @doc """
  Merges a keyword list of overrides into the default theme.

  Colour values may be given as raw ANSI escape binaries or as
  `{Color.input(), keyword()}` tuples that will be resolved via
  `Color.ANSI.to_string/2`.  Map-valued fields (`:syntax`,
  `:table_chars`) have their individual values resolved recursively.

      Marcli.Theme.merge(h1: "\\e[1;31m")
      #=> %Marcli.Theme{h1: "\\e[1;31m", ...defaults...}

      Marcli.Theme.merge(h1: {"red", mode: :truecolor})
      #=> %Marcli.Theme{h1: "\\e[38;2;255;0;0m", ...defaults...}
  """
  @spec merge(keyword()) :: t()
  def merge(overrides) when is_list(overrides) do
    Enum.reduce(overrides, default(), fn
      {key, value}, acc when is_map_key(acc, key) ->
        case {Map.get(acc, key), value} do
          {%{}, nil} ->
            acc

          {%{} = existing, %{} = value} ->
            # credo:disable-for-next-line
            resolved = Map.new(value, fn {k, v} -> {k, resolve_color(v)} end)
            %{acc | key => Map.merge(existing, resolved)}

          _ ->
            %{acc | key => resolve_color(value)}
        end

      _, acc ->
        acc
    end)
  end

  def merge(%__MODULE__{} = theme), do: theme

  @doc "Returns the default syntax highlighting color map."
  @spec default_syntax :: %{atom() => String.t()}
  def default_syntax, do: @default_syntax

  @doc """
  Resolves a colour value to an ANSI escape binary.

  Returns binaries unchanged.  For `{Color.input(), keyword()}`
  tuples, delegates to `Color.ANSI.to_string/2` (requires the
  optional `:color` dependency).

  ## Examples

      iex> Marcli.Theme.resolve_color("\\e[31m")
      "\\e[31m"

      iex> Marcli.Theme.resolve_color({"red", []})
      "\\e[38;2;255;0;0m"

      iex> Marcli.Theme.resolve_color({"#00ff00", mode: :ansi256})
      "\\e[38;5;46m"

  """
  @spec resolve_color(color_input()) :: String.t()
  def resolve_color(value)

  def resolve_color(binary) when is_binary(binary), do: binary

  def resolve_color({color, opts}) when is_list(opts) do
    unless Code.ensure_loaded?(Color.ANSI) do
      raise ArgumentError,
            "tuple colour values require the :color dependency " <>
              "({:color, \"~> 0.4\"} in mix.exs)"
    end

    # credo:disable-for-next-line
    apply(Color.ANSI, :to_string, [color, opts])
  end

  def resolve_color(other), do: other
end
