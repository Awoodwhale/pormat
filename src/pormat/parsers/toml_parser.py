"""TOML parser."""

from typing import Any

import tomli


class TomlParser:
    """Parser for TOML format."""

    @staticmethod
    def parse(content: str) -> Any:
        """Parse TOML content.

        Args:
            content: The TOML string to parse.

        Returns:
            The parsed Python object.

        Raises:
            tomli.TOMLDecodeError: If content is not valid TOML.
        """
        return tomli.loads(content)
