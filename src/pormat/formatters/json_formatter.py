"""JSON formatter."""

import json
from typing import Any


class JsonFormatter:
    """Formatter for JSON output."""

    @staticmethod
    def _default(obj: Any) -> Any:
        """Handle non-JSON serializable types.

        Args:
            obj: The object to serialize.

        Returns:
            A JSON-serializable representation of the object.
        """
        if isinstance(obj, bytes):
            return obj.decode('utf-8', errors='replace')
        if isinstance(obj, bytearray):
            return obj.decode('utf-8', errors='replace')
        if hasattr(obj, '__dict__'):
            return obj.__dict__
        return str(obj)

    @staticmethod
    def format(data: Any, indent: int = 4, compact: bool = False) -> str:
        """Format data as JSON.

        Args:
            data: The data to format.
            indent: Number of spaces for indentation.
            compact: If True, output compact single-line format.

        Returns:
            Formatted JSON string.
        """
        if compact:
            return json.dumps(data, ensure_ascii=False, separators=(",", ":"), default=JsonFormatter._default).strip()
        return json.dumps(data, indent=indent, ensure_ascii=False, default=JsonFormatter._default).strip()
