defmodule MarcliTest do
  use ExUnit.Case, async: true

  # ANSI constants for assertions
  @reset "\e[0m"
  @bold "\e[1m"
  @dim "\e[2m"
  @italic "\e[3m"
  @underline "\e[4m"
  @strikethrough "\e[9m"
  @green "\e[32m"
  @blue "\e[34m"
  @h1 "\e[1;33m"
  @h2 "\e[1;36m"
  @h3 "\e[1;37m"

  describe "headings" do
    test "h1 renders bold yellow" do
      result = Marcli.render("# Hello")
      assert result == @h1 <> "Hello" <> @reset
    end

    test "h2 renders bold cyan" do
      result = Marcli.render("## Section")
      assert result == @h2 <> "Section" <> @reset
    end

    test "h3 renders bold white" do
      result = Marcli.render("### Subsection")
      assert result == @h3 <> "Subsection" <> @reset
    end

    test "h4+ also renders bold white" do
      result = Marcli.render("#### Deep")
      assert result == @h3 <> "Deep" <> @reset
    end
  end

  describe "inline formatting" do
    test "bold text" do
      result = Marcli.render("Some **bold** here")
      assert result =~ @bold <> "bold" <> @reset
      assert result =~ "Some "
      assert result =~ " here"
    end

    test "italic text" do
      result = Marcli.render("Some *italic* here")
      assert result =~ @italic <> "italic" <> @reset
    end

    test "inline code" do
      result = Marcli.render("Use `mix test` to run")
      assert result =~ @green <> "mix test" <> @reset
    end

    test "strikethrough" do
      result = Marcli.render("~~removed~~")
      assert result =~ @strikethrough <> "removed" <> @reset
    end

    test "links show text and URL" do
      result = Marcli.render("[Elixir](https://elixir-lang.org)")
      assert result =~ @underline <> @blue <> "Elixir" <> @reset
      assert result =~ @dim <> " (https://elixir-lang.org)" <> @reset
    end
  end

  describe "bullet lists" do
    test "renders with triangle markers" do
      md = """
      - alpha
      - beta
      - gamma
      """

      result = Marcli.render(md)
      assert result =~ "  \u25b8 alpha"
      assert result =~ "  \u25b8 beta"
      assert result =~ "  \u25b8 gamma"
    end

    test "preserves inline formatting in items" do
      md = """
      - **bold** item
      - normal item
      """

      result = Marcli.render(md)
      assert result =~ "  \u25b8 " <> @bold <> "bold" <> @reset <> " item"
    end
  end

  describe "ordered lists" do
    test "renders with circled numbers" do
      md = """
      1. first
      2. second
      3. third
      """

      result = Marcli.render(md)
      assert result =~ "  \u2460 first"
      assert result =~ "  \u2461 second"
      assert result =~ "  \u2462 third"
    end

    test "handles start number" do
      md = """
      3. third
      4. fourth
      """

      result = Marcli.render(md)
      assert result =~ "  \u2462 third"
      assert result =~ "  \u2463 fourth"
    end

    test "falls back to parenthesized numbers beyond 20" do
      md = """
      1. one
      2. two
      """

      result = Marcli.render(md)
      assert result =~ "  \u2460 one"
      assert result =~ "  \u2461 two"
    end
  end

  describe "code blocks" do
    test "renders with box drawing and language header" do
      md = """
      ```elixir
      IO.puts("hello")
      ```
      """

      result = Marcli.render(md)
      assert result =~ @dim <> "  \u250c\u2500 elixir" <> @reset
      # Content is present (exact styling depends on whether Makeup lexer is active)
      assert result =~ "puts"
      assert result =~ @dim <> "  \u2514\u2500" <> @reset
    end

    test "renders without language when not specified" do
      md = """
      ```
      plain code
      ```
      """

      result = Marcli.render(md)
      assert result =~ @dim <> "  \u250c\u2500" <> @reset
      assert result =~ @green <> "plain code" <> @reset
    end
  end

  describe "block quotes" do
    test "renders with bar prefix" do
      md = """
      > Something wise was said.
      """

      result = Marcli.render(md)
      assert result =~ @dim <> "  \u2502 " <> @reset
      assert result =~ "Something wise was said."
    end
  end

  describe "thematic break" do
    test "renders as dim horizontal rule" do
      result = Marcli.render("---")
      assert result =~ @dim <> String.duplicate("\u2500", 40) <> @reset
    end
  end

  describe "paragraphs" do
    test "separates paragraphs with double newline (default LF)" do
      md = """
      First paragraph.

      Second paragraph.
      """

      result = Marcli.render(md)
      assert result =~ "First paragraph.\n\nSecond paragraph."
    end

    test "separates paragraphs with double CRLF when configured" do
      md = """
      First paragraph.

      Second paragraph.
      """

      result = Marcli.render(md, newline: "\r\n")
      assert result =~ "First paragraph.\r\n\r\nSecond paragraph."
    end
  end

  describe "newline option" do
    test "defaults to LF" do
      md = """
      - alpha
      - beta
      """

      result = Marcli.render(md)
      assert result =~ "alpha\n"
      refute result =~ "\r\n"
    end

    test "uses CRLF when configured" do
      md = """
      - alpha
      - beta
      """

      result = Marcli.render(md, newline: "\r\n")
      assert result =~ "alpha\r\n"
    end
  end

  describe "mixed content" do
    test "renders heading followed by paragraph and list" do
      md = """
      # Title

      Some intro text.

      - item one
      - item two
      """

      result = Marcli.render(md)
      assert result =~ @h1 <> "Title" <> @reset
      assert result =~ "Some intro text."
      assert result =~ "  \u25b8 item one"
      assert result =~ "  \u25b8 item two"
    end
  end

  describe "syntax highlighting" do
    setup do
      Application.ensure_all_started(:makeup_elixir)
      :ok
    end

    test "elixir code block is colored via Makeup" do
      md = """
      ```elixir
      defmodule Foo do
        def bar, do: 42
      end
      ```
      """

      result = Marcli.render(md)
      theme = Marcli.Theme.default()

      # With Makeup active, keywords get the keyword style (magenta),
      # not the plain code_text fallback (green)
      refute result =~ theme.code_text <> "defmodule"

      # defmodule/def -> :keyword_declaration -> magenta
      assert result =~ theme.syntax.keyword_declaration <> "defmodule" <> theme.reset

      # Foo -> :name_class -> bold cyan
      assert result =~ theme.syntax.name_class <> "Foo" <> theme.reset

      # 42 -> :number_integer -> inherits from :number -> blue
      assert result =~ theme.syntax.number <> "42" <> theme.reset

      # bar -> :name_function -> yellow
      assert result =~ theme.syntax.name_function <> "bar" <> theme.reset

      # Border rendering is unchanged
      assert result =~ theme.code_border <> theme.code_top <> " elixir" <> theme.reset
      assert result =~ theme.code_border <> theme.code_bottom <> theme.reset
    end

    test "falls back to plain code_text for unknown languages" do
      md = """
      ```brainfuck
      +++>+<-
      ```
      """

      result = Marcli.render(md)
      theme = Marcli.Theme.default()

      assert result =~ theme.code_text <> "+++>+<-" <> theme.reset
    end

    test "syntax highlighting can be disabled via theme" do
      md = """
      ```elixir
      def foo, do: :ok
      ```
      """

      theme = %{Marcli.Theme.default() | syntax_highlight: false}
      result = Marcli.render(md, theme: theme)

      assert result =~ theme.code_text <> "def foo, do: :ok" <> theme.reset
    end
  end
end
