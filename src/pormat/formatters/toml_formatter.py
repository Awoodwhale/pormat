"""TOML formatter."""

from typing import Any

import tomli_w


class TomlFormatter:
    """Formatter for TOML output."""

    @staticmethod
    def format(data: Any, indent: int = 4, compact: bool = False) -> str:
        """Format data as TOML.

        Args:
            data: The data to format (must be a dict).
            indent: Number of spaces for indentation (TOML uses fixed indentation).
            compact: If True, output compact format (not supported for TOML, ignored).

        Returns:
            Formatted TOML string.

        Note:
            TOML specification requires fixed formatting rules, so indent and compact
            options have limited effect. The output follows tomli-w's default formatting.
            TOML only supports dict/object as the root structure.

        Raises:
            ValueError: If data is not a dict or contains None values (TOML doesn't support null).
        """
        # TOML only supports dict/object as root structure
        # Convert bytes to string first, then check if dict
        if isinstance(data, (bytes, bytearray)):
            data = data.decode('utf-8', errors='replace')
        if not isinstance(data, dict):
            raise ValueError(
                f"TOML format requires a dict/object as root structure, got {type(data).__name__}"
            )

        # TOML doesn't support null/None values, so we need to filter them out
        cleaned_data = TomlFormatter._remove_none_values(data)

        # TOML has strict formatting rules, so we ignore compact
        return tomli_w.dumps(cleaned_data, indent=indent).strip()

    @staticmethod
    def _remove_none_values(data: Any) -> Any:
        """Recursively remove None values from data structure.

        TOML doesn't support null values, so we need to remove them before serialization.

        Args:
            data: The data to clean (dict, list, or primitive type).

        Returns:
            Data with None values removed and non-TOML types converted.
        """
        if isinstance(data, (bytes, bytearray)):
            return data.decode('utf-8', errors='replace')
        if isinstance(data, dict):
            return {
                k: TomlFormatter._remove_none_values(v)
                for k, v in data.items()
                if v is not None
            }
        elif isinstance(data, list):
            return [TomlFormatter._remove_none_values(item) for item in data if item is not None]
        return data
