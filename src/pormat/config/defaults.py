"""Default configuration values."""

from typing import Literal

DEFAULT_FORMAT: Literal["json", "yaml", "python", "toml"] = "json"
DEFAULT_INDENT: int = 4
DEFAULT_COLOR: bool = True
DEFAULT_THEME: str = "monokai"
DEFAULT_CONFIG = {
    "default_format": DEFAULT_FORMAT,
    "default_indent": DEFAULT_INDENT,
    "default_color": DEFAULT_COLOR,
    "default_theme": DEFAULT_THEME,
}
