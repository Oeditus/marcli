defmodule Marcli.ThemeTest do
  use ExUnit.Case, async: true

  alias Marcli.Theme

  describe "resolve_color/1" do
    test "returns binaries unchanged" do
      assert Theme.resolve_color("\e[1;33m") == "\e[1;33m"
      assert Theme.resolve_color("") == ""
    end

    test "resolves {color, []} tuple to truecolor ANSI by default" do
      assert Theme.resolve_color({"red", []}) == "\e[38;2;255;0;0m"
    end

    test "resolves CSS named colour" do
      result = Theme.resolve_color({"rebeccapurple", []})
      assert is_binary(result)
      assert String.starts_with?(result, "\e[")
    end

    test "resolves hex string input" do
      assert Theme.resolve_color({"#ff0000", []}) == "\e[38;2;255;0;0m"
    end

    test "respects mode: :ansi256" do
      result = Theme.resolve_color({"red", mode: :ansi256})
      assert result == "\e[38;5;196m"
    end

    test "respects mode: :ansi16" do
      result = Theme.resolve_color({"red", mode: :ansi16})
      assert is_binary(result)
      assert String.starts_with?(result, "\e[")
    end

    test "respects layer: :background" do
      result = Theme.resolve_color({"red", layer: :background})
      assert result == "\e[48;2;255;0;0m"
    end

    test "passes through non-binary, non-tuple values" do
      assert Theme.resolve_color(42) == 42
      assert Theme.resolve_color(true) == true
    end
  end

  describe "merge/1 with color tuples" do
    test "resolves color tuple for a scalar field" do
      theme = Theme.merge(h1: {"red", []})
      assert theme.h1 == "\e[38;2;255;0;0m"
    end

    test "resolves color tuple with options" do
      theme = Theme.merge(h1: {"red", mode: :ansi256})
      assert theme.h1 == "\e[38;5;196m"
    end

    test "resolves color tuples inside syntax map" do
      theme = Theme.merge(syntax: %{keyword: {"blue", []}})
      assert theme.syntax.keyword == "\e[38;2;0;0;255m"
      # other syntax entries remain at defaults
      assert theme.syntax.comment == "\e[3;90m"
    end

    test "keeps binary values unchanged in merge" do
      theme = Theme.merge(h1: "\e[1;31m")
      assert theme.h1 == "\e[1;31m"
    end

    test "mixes binary and tuple overrides in a single merge" do
      theme = Theme.merge(h1: {"#00ff00", []}, h2: "\e[1;35m")
      assert theme.h1 == "\e[38;2;0;255;0m"
      assert theme.h2 == "\e[1;35m"
    end

    test "non-color fields are untouched by resolve_color passthrough" do
      theme = Theme.merge(thematic_break_width: 80)
      assert theme.thematic_break_width == 80
    end
  end

  describe "full render with color-tuple theme" do
    test "renders heading with color-resolved h1" do
      theme = Theme.merge(h1: {"#ff9900", []})
      result = Marcli.render("# Hello", theme: theme)
      assert result =~ "\e[38;2;255;153;0m" <> "Hello"
    end
  end
end
