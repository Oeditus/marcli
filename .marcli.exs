# Marcli Theme Configuration
#
# This file defines the visual theme for terminal Markdown rendering.
# Modify any value below to customize the output. Remove a key to
# fall back to its built-in default.
#
# Load with:
#
#   theme = Marcli.Theme.load(".marcli.exs")
#   Marcli.render(markdown, theme: theme)
#
# ANSI escape reference:
#
#   \e[0m  reset        \e[1m  bold        \e[2m  dim
#   \e[3m  italic       \e[4m  underline   \e[9m  strikethrough
#   \e[30m black        \e[31m red         \e[32m green
#   \e[33m yellow       \e[34m blue        \e[35m magenta
#   \e[36m cyan         \e[37m white
#   \e[1;33m bold+yellow (combine with semicolons)

[
  # -- Reset sequence ---------------------------------------------------------
  reset: "\e[0m",

  # -- Headings ---------------------------------------------------------------
  h1: "\e[1;33m",
  h2: "\e[1;36m",
  h3: "\e[1;37m",

  # -- Inline styles ----------------------------------------------------------
  bold: "\e[1m",
  italic: "\e[3m",
  strikethrough: "\e[9m",
  inline_code: "\e[32m",

  # -- Links ------------------------------------------------------------------
  link_text: "\e[4m\e[34m",
  link_url: "\e[2m",

  # -- Images -----------------------------------------------------------------
  image_text: "\e[2m",
  image_prefix: "[image: ",
  image_suffix: "]",
  image_url: "\e[2m",

  # -- Code blocks ------------------------------------------------------------
  code_border: "\e[2m",
  code_text: "\e[32m",
  code_top: "  ┌─",
  code_left: "  │ ",
  code_bottom: "  └─",

  # -- Block quotes -----------------------------------------------------------
  block_quote: "\e[2m",
  block_quote_prefix: "  │ ",

  # -- Bullet lists -----------------------------------------------------------
  bullet_marker: "  ▸ ",
  task_checked: "  ☑ ",
  task_unchecked: "  ☐ ",

  # -- Ordered lists ----------------------------------------------------------
  ordered_indent: "  ",
  ordered_glyphs: ~w(① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮ ⑯ ⑰ ⑱ ⑲ ⑳),

  # -- List continuation indent (loose list items) ----------------------------
  list_continuation: "    ",

  # -- Thematic breaks --------------------------------------------------------
  thematic_break: "\e[2m",
  thematic_break_char: "─",
  thematic_break_width: 40,

  # -- HTML blocks ------------------------------------------------------------
  html_block: "\e[2m"
]
