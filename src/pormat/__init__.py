"""Pormat - A CLI tool to format and convert data (JSON/YAML/Python) in the terminal."""

from pormat.cli import app

__version__ = "0.1.0"


def main() -> None:
    """Entry point for the pormat CLI."""
    app()
