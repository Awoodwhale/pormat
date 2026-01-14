"""Python literal formatter."""

import pprint
from typing import Any


class PythonFormatter:
    """Formatter for Python literal output."""

    @staticmethod
    def format(data: Any, indent: int = 4, compact: bool = False) -> str:
        """Format data as Python literal.

        Args:
            data: The data to format.
            indent: Number of spaces for indentation.
            compact: If True, output compact single-line format.

        Returns:
            Formatted Python literal string.
        """
        if compact:
            return repr(data).strip()
        # Use pprint with custom width based on indent
        # Width affects when pprint breaks lines
        width = 100 - indent * 2
        formatted = pprint.pformat(data, indent=indent, width=width)
        return formatted.strip()
