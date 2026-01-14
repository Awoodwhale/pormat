"""YAML parser."""

from typing import Any

import yaml


class YamlParser:
    """Parser for YAML format."""

    @staticmethod
    def parse(content: str) -> Any:
        """Parse YAML content.

        Args:
            content: The YAML string to parse.

        Returns:
            The parsed Python object.

        Raises:
            yaml.YAMLError: If content is not valid YAML.
        """
        return yaml.safe_load(content)
