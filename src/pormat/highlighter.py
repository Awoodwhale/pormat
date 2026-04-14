"""Syntax highlighting for formatted output using Pygments."""

from pygments import highlight
from pygments.formatters import Terminal256Formatter
from pygments.lexers import get_lexer_by_name


def highlight_output(text: str, format_name: str, theme: str = "monokai") -> str:
    """Apply syntax highlighting to formatted text.

    Args:
        text: The formatted text to highlight.
        format_name: The format name (json, yaml, toml, python).
        theme: The Pygments theme name for highlighting.

    Returns:
        The highlighted string with ANSI escape codes.
    """
    lexer = get_lexer_by_name(format_name)
    formatter = Terminal256Formatter(style=theme)
    return highlight(text, lexer, formatter).rstrip('\n')
