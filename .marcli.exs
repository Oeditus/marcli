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
  html_block: "\e[2m",

  # -- Tables -----------------------------------------------------------------
  table_border: "\e[2m",
  table_header: "\e[1m",
  table_chars: %{
    tl: "┌", tr: "┐", bl: "└", br: "┘",    # corners
    h: "─", v: "│",                           # horizontal / vertical
    tm: "┬", bm: "┴",                         # top-mid / bottom-mid
    lm: "├", rm: "┤",                         # left-mid / right-mid
    x: "┼"                                     # cross
  },

  # -- Syntax highlighting (Makeup integration) -------------------------------
  # Set to false to disable Makeup-based syntax highlighting in code blocks.
  syntax_highlight: true,

  # Token type -> ANSI escape mapping for syntax highlighting.
  # Override individual token types; unspecified types inherit from their
  # parent (e.g. :keyword_constant inherits from :keyword).
  syntax: %{
    # Comments
    comment: "\e[3;90m",             # italic gray
    # Errors
    error: "\e[1;31m",               # bold red
    # Keywords
    keyword: "\e[35m",               # magenta
    keyword_constant: "\e[36m",      # cyan
    keyword_declaration: "\e[35m",   # magenta
    keyword_namespace: "\e[35m",     # magenta
    keyword_pseudo: "\e[35m",        # magenta
    keyword_reserved: "\e[35m",      # magenta
    keyword_type: "\e[36m",          # cyan
    # Names
    name_attribute: "\e[33m",        # yellow
    name_builtin: "\e[36m",          # cyan
    name_builtin_pseudo: "\e[36m",   # cyan
    name_class: "\e[1;36m",          # bold cyan
    name_constant: "\e[1;33m",       # bold yellow
    name_decorator: "\e[33m",        # yellow
    name_entity: "\e[1;33m",         # bold yellow
    name_exception: "\e[1;31m",      # bold red
    name_function: "\e[33m",         # yellow
    name_function_magic: "\e[33m",   # yellow
    name_label: "\e[36m",            # cyan
    name_namespace: "\e[1;36m",      # bold cyan
    name_tag: "\e[1;35m",            # bold magenta
    name_variable: "\e[37m",         # white
    # Strings
    string: "\e[32m",                # green
    string_char: "\e[32m",           # green
    string_delimiter: "\e[32m",      # green
    string_doc: "\e[3;32m",          # italic green
    string_escape: "\e[1;32m",       # bold green
    string_interpol: "\e[1;32m",     # bold green
    string_regex: "\e[31m",          # red
    string_sigil: "\e[32m",          # green
    string_symbol: "\e[36m",         # cyan
    # Numbers
    number: "\e[34m",                # blue
    # Operators
    operator: "",                      # default
    operator_word: "\e[35m",         # magenta
    # Punctuation
    punctuation: "",                   # default
    # Generic (diffs, prompts, etc.)
    generic_deleted: "\e[31m",       # red
    generic_emph: "\e[3m",           # italic
    generic_error: "\e[31m",         # red
    generic_heading: "\e[1m",        # bold
    generic_inserted: "\e[32m",      # green
    generic_output: "\e[90m",        # bright black
    generic_prompt: "\e[1m",         # bold
    generic_strong: "\e[1m",         # bold
    generic_subheading: "\e[1;35m",  # bold magenta
    generic_traceback: "\e[31m"      # red
  }
]
