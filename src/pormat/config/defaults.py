"""Default configuration values."""

from typing import Literal

DEFAULT_FORMAT: Literal["json", "yaml", "python", "toml"] = "json"
DEFAULT_INDENT: int = 4
DEFAULT_CONFIG = {
    "default_format": DEFAULT_FORMAT,
    "default_indent": DEFAULT_INDENT,
}
