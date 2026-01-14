"""Configuration file loader."""

import json
from pathlib import Path
from typing import Literal

import tomli
import yaml
from dotenv import dotenv_values

from pormat.config.defaults import DEFAULT_CONFIG

FormatType = Literal["json", "yaml", "python", "toml"]


class Config:
    """Configuration for pormat."""

    def __init__(
        self,
        format: FormatType = "json",
        indent: int = 4,
    ):
        self.format = format
        self.indent = indent

    @classmethod
    def from_dict(cls, data: dict) -> "Config":
        """Create Config from dictionary."""
        return cls(
            format=data.get("default_format", "json"),
            indent=data.get("default_indent", 4),
        )


def _find_config_file(custom_path: str | None = None) -> Path | None:
    """Find configuration file in standard locations.

    Search order:
        1. Custom path (if provided)
        2. ./pormat.yml, ./pormat.yaml
        3. ./pormat.toml
        4. ./pormat.json
        5. .pormat.yml, .pormat.yaml
        6. .pormat.toml, .pormat.json
        7. .env (with PORMAT_* prefix)
        8. ~/.config/pormat/config.yml
        9. ~/.pormat.yml
    """
    if custom_path:
        path = Path(custom_path)
        if path.exists():
            return path
        return None

    # Current directory
    cwd = Path.cwd()
    config_names = [
        "pormat.yml",
        "pormat.yaml",
        "pormat.toml",
        "pormat.json",
        ".pormat.yml",
        ".pormat.yaml",
        ".pormat.toml",
        ".pormat.json",
    ]

    for name in config_names:
        path = cwd / name
        if path.exists():
            return path

    # .env file
    env_path = cwd / ".env"
    if env_path.exists():
        return env_path

    # User config directory
    home = Path.home()
    user_config_paths = [
        home / ".config" / "pormat" / "config.yml",
        home / ".pormat.yml",
    ]

    for path in user_config_paths:
        if path.exists():
            return path

    return None


def _load_yaml(path: Path) -> dict:
    """Load YAML configuration file."""
    with open(path, "r") as f:
        return yaml.safe_load(f) or {}


def _load_toml(path: Path) -> dict:
    """Load TOML configuration file."""
    with open(path, "rb") as f:
        return tomli.load(f)


def _load_json(path: Path) -> dict:
    """Load JSON configuration file."""
    with open(path, "r") as f:
        return json.load(f)


def _load_env(path: Path) -> dict:
    """Load .env configuration file with PORMAT_ prefix."""
    values = dotenv_values(path)
    # Convert PORMAT_* keys to config keys
    config = {}
    for key, value in values.items():
        if key.startswith("PORMAT_"):
            config_key = key.removeprefix("PORMAT_").lower()
            # Convert format to lowercase
            if config_key == "format":
                value = value.lower()
            # Convert indent to int
            elif config_key == "indent":
                value = int(value)
            config[f"default_{config_key}"] = value
    return config


def load_config(custom_path: str | None = None) -> Config:
    """Load configuration from file or use defaults.

    Args:
        custom_path: Optional custom configuration file path.

    Returns:
        Config object with loaded or default values.
    """
    config_path = _find_config_file(custom_path)

    if config_path is None:
        return Config.from_dict(DEFAULT_CONFIG)

    # Load based on file extension
    suffix = config_path.suffix.lower()

    loaders: dict[str, callable] = {
        ".yml": _load_yaml,
        ".yaml": _load_yaml,
        ".toml": _load_toml,
        ".json": _load_json,
        ".env": _load_env,
    }

    loader = loaders.get(suffix)
    if loader is None:
        return Config.from_dict(DEFAULT_CONFIG)

    try:
        data = loader(config_path)
        return Config.from_dict(data)
    except Exception:
        # If loading fails, use defaults
        return Config.from_dict(DEFAULT_CONFIG)
