<img src="https://raw.githubusercontent.com/Oeditus/marcli/v0.1.0/stuff/img/logo-128x128.png" alt="Marcli" width="128" align="right">

# Marcli

**CommonMark Markdown to ANSI-escaped terminal output**

Marcli converts Markdown into styled terminal text using ANSI escape sequences.
It parses via [MDEx](https://hexdocs.pm/mdex) and renders headings, lists, code blocks,
inline formatting, links, images, and more as richly styled output for terminal emulators.

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
- Shortcodes (emoji)

## Installation

Add `marcli` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:marcli, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
# Basic rendering
output = Marcli.render("# Hello\n\nSome **bold** text.")
IO.puts(output)

# With CRLF line endings (e.g. for xterm.js)
output = Marcli.render(markdown, newline: "\r\n")
```

## Options

- `:newline` -- the line ending to use (default: `"\n"`). Pass `"\r\n"` for xterm.js or other terminals that require CRLF.

## Documentation

[HexDocs](https://hexdocs.pm/marcli)

## Credits

Created as part of the [Oeditus](https://oeditus.com) code quality tooling ecosystem.

## License

MIT

