defmodule Marcli do
  @moduledoc """
  Converts CommonMark Markdown to ANSI-escaped terminal output.

  Parses Markdown via MDEx and produces strings with ANSI escape
  sequences suitable for terminal rendering.

  ## Supported Elements

  - Headings (h1: bold yellow, h2: bold cyan, h3+: bold white)
  - Bold, italic, strikethrough, inline code
  - Bullet lists (triangle markers) and ordered lists (circled numbers)
  - Code blocks with optional language headers
  - Block quotes (vertical bar prefix)
  - Thematic breaks (horizontal rules)
  - Links (underlined blue with dimmed URL)
  - Images (bracketed alt text with URL)
  - Task list items (checkbox markers)

  ## Options

  - `:newline` -- the line ending to use (default: `"\\n"`).
    Pass `"\\r\\n"` for xterm.js or other terminals that require CRLF.
  - `:theme` -- a `Marcli.Theme` struct controlling all visual styles.
    Defaults to `Marcli.Theme.default()`.

  ## Example

      output = Marcli.render("# Hello\\n\\nSome **bold** text.")
      output = Marcli.render(markdown, newline: "\\r\\n")

      theme = Marcli.Theme.load(".marcli.exs")
      output = Marcli.render(markdown, theme: theme)
  """

  alias Marcli.Theme

  @parse_opts [
    extension: [
      strikethrough: true,
      tasklist: true,
      table: true,
      autolink: true,
      shortcodes: true
    ]
  ]

  @type option :: {:newline, String.t()} | {:theme, Theme.t()}

  @doc """
  Renders a Markdown string as ANSI-escaped terminal output.

  Returns a string with embedded ANSI escape sequences. Line endings
  default to `"\\n"` but can be overridden with the `:newline` option.

  ## Options

  - `:newline` -- the line ending sequence (default: `"\\n"`)
  - `:theme` -- a `Marcli.Theme` struct (default: `Marcli.Theme.default()`)
  """
  @spec render(String.t(), [option()]) :: String.t()
  def render(markdown, opts \\ []) when is_binary(markdown) do
    theme = Keyword.get(opts, :theme, Theme.default())
    nl = Keyword.get(opts, :newline, "\n")

    markdown
    |> MDEx.parse_document!(@parse_opts)
    |> render_document(nl, theme)
  end

  defp render_document(%MDEx.Document{nodes: nodes}, nl, theme) do
    nodes
    |> Enum.map(&render_block(&1, nl, theme))
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(nl <> nl)
  end

  # -- Block-level nodes ----------------------------------------------------

  defp render_block(%MDEx.Heading{level: 1, nodes: children}, _nl, theme),
    do: theme.h1 <> render_inline(children, theme) <> theme.reset

  defp render_block(%MDEx.Heading{level: 2, nodes: children}, _nl, theme),
    do: theme.h2 <> render_inline(children, theme) <> theme.reset

  defp render_block(%MDEx.Heading{level: _level, nodes: children}, _nl, theme),
    do: theme.h3 <> render_inline(children, theme) <> theme.reset

  defp render_block(%MDEx.Paragraph{nodes: children}, _nl, theme),
    do: render_inline(children, theme)

  defp render_block(%MDEx.List{list_type: :bullet, nodes: items}, nl, theme) do
    Enum.map_join(items, nl, &render_bullet_item(&1, nl, theme))
  end

  defp render_block(%MDEx.List{list_type: :ordered, nodes: items, start: start}, nl, theme) do
    items
    |> Enum.with_index(start || 1)
    |> Enum.map_join(nl, fn {item, idx} -> render_ordered_item(item, idx, nl, theme) end)
  end

  defp render_block(%MDEx.CodeBlock{literal: literal, info: info}, nl, theme) do
    code = String.trim_trailing(literal, "\n")
    lines = String.split(code, "\n")

    header =
      if is_binary(info) and info != "",
        do: theme.code_border <> theme.code_top <> " " <> info <> theme.reset <> nl,
        else: theme.code_border <> theme.code_top <> theme.reset <> nl

    body =
      Enum.map_join(lines, nl, fn line ->
        theme.code_border <> theme.code_left <> theme.reset <> theme.code_text <> line <> theme.reset
      end)

    footer = nl <> theme.code_border <> theme.code_bottom <> theme.reset

    header <> body <> footer
  end

  defp render_block(%MDEx.BlockQuote{nodes: children}, nl, theme) do
    children
    |> Enum.map_join(nl, &render_block(&1, nl, theme))
    |> String.split(nl)
    |> Enum.map_join(nl, fn line ->
      theme.block_quote <> theme.block_quote_prefix <> theme.reset <> line
    end)
  end

  defp render_block(%MDEx.ThematicBreak{}, _nl, theme),
    do:
      theme.thematic_break <>
        String.duplicate(theme.thematic_break_char, theme.thematic_break_width) <> theme.reset

  defp render_block(%MDEx.HtmlBlock{literal: literal}, _nl, theme),
    do: theme.html_block <> String.trim_trailing(literal, "\n") <> theme.reset

  # Catch-all for unknown block nodes with children or literal
  defp render_block(%{nodes: children}, nl, theme) when is_list(children),
    do: Enum.map_join(children, nl, &render_block(&1, nl, theme))

  defp render_block(%{literal: literal}, _nl, _theme) when is_binary(literal), do: literal
  defp render_block(_node, _nl, _theme), do: ""

  # -- List items -----------------------------------------------------------

  defp render_bullet_item(%MDEx.TaskItem{checked: true, nodes: children}, nl, theme),
    do: theme.task_checked <> render_item_content(children, nl, theme)

  defp render_bullet_item(%MDEx.TaskItem{checked: false, nodes: children}, nl, theme),
    do: theme.task_unchecked <> render_item_content(children, nl, theme)

  defp render_bullet_item(%MDEx.ListItem{nodes: children}, nl, theme),
    do: theme.bullet_marker <> render_item_content(children, nl, theme)

  defp render_bullet_item(other, nl, theme), do: render_block(other, nl, theme)

  defp render_ordered_item(%MDEx.ListItem{nodes: children}, idx, nl, theme),
    do: theme.ordered_indent <> glyph(idx, theme) <> " " <> render_item_content(children, nl, theme)

  defp render_ordered_item(other, _idx, nl, theme), do: render_block(other, nl, theme)

  # Tight list items contain a single paragraph; loose items may contain several blocks.
  defp render_item_content([%MDEx.Paragraph{nodes: children}], _nl, theme),
    do: render_inline(children, theme)

  defp render_item_content(nodes, nl, theme) do
    Enum.map_join(nodes, nl <> theme.list_continuation, fn
      %MDEx.Paragraph{nodes: children} -> render_inline(children, theme)
      block -> render_block(block, nl, theme)
    end)
  end

  # -- Inline nodes ---------------------------------------------------------

  defp render_inline(nodes, theme) when is_list(nodes),
    do: Enum.map_join(nodes, &render_inline_node(&1, theme))

  defp render_inline_node(%MDEx.Text{literal: text}, _theme), do: text

  defp render_inline_node(%MDEx.Strong{nodes: children}, theme),
    do: theme.bold <> render_inline(children, theme) <> theme.reset

  defp render_inline_node(%MDEx.Emph{nodes: children}, theme),
    do: theme.italic <> render_inline(children, theme) <> theme.reset

  defp render_inline_node(%MDEx.Strikethrough{nodes: children}, theme),
    do: theme.strikethrough <> render_inline(children, theme) <> theme.reset

  defp render_inline_node(%MDEx.Code{literal: text}, theme),
    do: theme.inline_code <> text <> theme.reset

  defp render_inline_node(%MDEx.Link{url: url, nodes: children}, theme) do
    theme.link_text <>
      render_inline(children, theme) <>
      theme.reset <>
      theme.link_url <> " (" <> url <> ")" <> theme.reset
  end

  defp render_inline_node(%MDEx.Image{url: url, nodes: children}, theme) do
    theme.image_text <>
      theme.image_prefix <>
      render_inline(children, theme) <>
      theme.image_suffix <>
      theme.reset <>
      theme.image_url <> " (" <> url <> ")" <> theme.reset
  end

  defp render_inline_node(%MDEx.SoftBreak{}, _theme), do: " "
  defp render_inline_node(%MDEx.LineBreak{}, _theme), do: "\n"

  defp render_inline_node(%MDEx.HtmlInline{literal: literal}, _theme), do: literal

  defp render_inline_node(%MDEx.ShortCode{emoji: emoji}, _theme) when is_binary(emoji), do: emoji

  # Catch-all for unknown inline nodes
  defp render_inline_node(%{literal: literal}, _theme) when is_binary(literal), do: literal

  defp render_inline_node(%{nodes: children}, theme) when is_list(children),
    do: render_inline(children, theme)

  defp render_inline_node(_node, _theme), do: ""

  # -- Helpers --------------------------------------------------------------

  defp glyph(n, theme) when n >= 1,
    do: Enum.at(theme.ordered_glyphs, n - 1) || "(#{n})"

  defp glyph(n, _theme), do: "(#{n})"
end
