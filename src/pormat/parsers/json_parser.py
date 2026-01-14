"""JSON parser."""

import json
from typing import Any


class JsonParser:
    """Parser for JSON format."""

    @staticmethod
    def parse(content: str) -> Any:
        """Parse JSON content.

        Args:
            content: The JSON string to parse.

        Returns:
            The parsed Python object.

        Raises:
            json.JSONDecodeError: If content is not valid JSON.
        """
        return json.loads(content)
