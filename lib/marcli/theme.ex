defmodule Marcli.Theme do
  @moduledoc """
  Theme configuration for terminal Markdown rendering.

  Every visual aspect of the rendered output is controlled by fields
  in this struct: ANSI escape sequences, marker characters, glyphs,
  box-drawing characters, and sizing.

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
            ordered_glyphs: ~w(\u2460 \u2461 \u2462 \u2463 \u2464 \u2465 \u2466 \u2467 \u2468 \u2469 \u246a \u246b \u246c \u246d \u246e \u246f \u2470 \u2471 \u2472 \u2473),

            # List continuation indent (for loose list items)
            list_continuation: "    ",

            # Thematic breaks
            thematic_break: "\e[2m",
            thematic_break_char: "\u2500",
            thematic_break_width: 40,

            # HTML blocks
            html_block: "\e[2m"

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
          html_block: String.t()
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

      Marcli.Theme.merge(h1: "\\e[1;31m")
      #=> %Marcli.Theme{h1: "\\e[1;31m", ...defaults...}
  """
  @spec merge(keyword()) :: t()
  def merge(overrides) when is_list(overrides), do: struct(default(), overrides)
  def merge(%__MODULE__{} = theme), do: theme
end
