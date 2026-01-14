"""YAML formatter."""

from typing import Any

import yaml


class YamlFormatter:
    """Formatter for YAML output."""

    @staticmethod
    def format(data: Any, indent: int = 4, compact: bool = False) -> str:
        """Format data as YAML.

        Args:
            data: The data to format.
            indent: Number of spaces for indentation.
            compact: If True, output compact single-line flow style format.

        Returns:
            Formatted YAML string.
        """
        if compact:
            return yaml.dump(
                data,
                allow_unicode=True,
                default_flow_style=True,
                sort_keys=False,
                width=float("inf"),
            ).strip()
        return yaml.dump(
            data,
            indent=indent,
            allow_unicode=True,
            default_flow_style=False,
            sort_keys=False,
        ).strip()
