"""Python literal parser."""

import ast
from typing import Any


class PythonParser:
    """Parser for Python literal syntax (dict, list, etc.)."""

    @staticmethod
    def parse(content: str) -> Any:
        """Parse Python literal content.

        Uses ast.literal_eval for safe evaluation.

        Args:
            content: The Python literal string to parse.

        Returns:
            The parsed Python object.

        Raises:
            ValueError: If content is not valid Python literal.
        """
        try:
            return ast.literal_eval(content)
        except (ValueError, SyntaxError) as e:
            raise ValueError(f"Invalid Python literal: {e}")
