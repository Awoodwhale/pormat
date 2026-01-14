"""Input format auto-detection."""

from typing import Literal

FormatType = Literal["json", "yaml", "python", "toml"]


def detect_format(content: str) -> FormatType:
    """Detect the format of input content.

    Detection strategy:
        Try each parser in order and return the first one that succeeds.

    Args:
        content: The input content string.

    Returns:
        The detected format: "json", "yaml", "python", or "toml".
    """
    # Try JSON first (most common for data tools, and strictest)
    if _try_parse_json(content):
        return "json"

    # Try TOML (has strict syntax, easy to detect)
    if _try_parse_toml(content):
        return "toml"

    # Try YAML (YAML is a superset of JSON, handles more cases)
    if _try_parse_yaml(content):
        # But don't confuse simple Python dict with YAML
        if not _looks_like_python_literal(content):
            return "yaml"

    # Try Python literal
    if _try_parse_python(content):
        return "python"

    # Default fallback - try YAML again as it's most permissive
    return "yaml"


def _try_parse_json(content: str) -> bool:
    """Try to parse content as JSON."""
    import json

    try:
        json.loads(content)
        return True
    except (json.JSONDecodeError, ValueError, TypeError):
        return False


def _try_parse_yaml(content: str) -> bool:
    """Try to parse content as YAML."""
    import yaml

    try:
        result = yaml.safe_load(content)
        return result is not None
    except (yaml.YAMLError, ValueError):
        return False


def _try_parse_toml(content: str) -> bool:
    """Try to parse content as TOML."""
    import tomli

    try:
        tomli.loads(content)
        return True
    except (tomli.TOMLDecodeError, ValueError):
        return False


def _try_parse_python(content: str) -> bool:
    """Try to parse content as Python literal."""
    import ast

    try:
        ast.literal_eval(content)
        return True
    except (ValueError, SyntaxError):
        return False


def _looks_like_python_literal(content: str) -> bool:
    """Check if content looks like Python literal (has single quotes, etc.)."""
    # Python dict/list often use single quotes for strings
    if "'" in content and content.count("'") >= 2:
        return True
    # Python literals
    if any(s in content for s in ["True", "False", "None"]):
        return True
    if any(s in content for s in ["r'", "rb'", "u'", "b'", 'r"', 'rb"', 'u"', 'b"']):
        return True
    return False
