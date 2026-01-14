"""CLI interface for pormat."""

from typing import Literal

import typer

from pormat.config.loader import load_config
from pormat.detector import detect_format
from pormat.formatters.json_formatter import JsonFormatter
from pormat.formatters.python_formatter import PythonFormatter
from pormat.formatters.toml_formatter import TomlFormatter
from pormat.formatters.yaml_formatter import YamlFormatter
from pormat.parsers.json_parser import JsonParser
from pormat.parsers.python_parser import PythonParser
from pormat.parsers.toml_parser import TomlParser
from pormat.parsers.yaml_parser import YamlParser
from pormat.utils.io import get_input

app = typer.Typer()

FormatType = Literal["json", "yaml", "python", "toml"]

# Formatters mapping
FORMATTERS = {
    "json": JsonFormatter,
    "yaml": YamlFormatter,
    "python": PythonFormatter,
    "toml": TomlFormatter,
}

# Parsers mapping
PARSERS = {
    "json": JsonParser,
    "yaml": YamlParser,
    "python": PythonParser,
    "toml": TomlParser,
}


@app.command()
def main(
    input: str = typer.Argument(
        None, help="Input string to format (or read from stdin)"
    ),
    format: FormatType = typer.Option(
        None, "-f", "--format", help="Output format: json, yaml, python, toml"
    ),
    indent: int = typer.Option(None, "-i", "--indent", help="Indentation spaces"),
    compact: bool = typer.Option(
        False, "-C", "--compact", help="Output compact single-line format"
    ),
    config: str = typer.Option(None, "-c", "--config", help="Custom config file path"),
) -> None:
    """Format data from stdin or direct input.

    Auto-detects input format and converts to specified output format.
    """
    # Load configuration
    cfg = load_config(config)

    # Override with CLI arguments (CLI takes priority)
    output_format: FormatType = format if format else cfg.format
    output_indent = indent if indent is not None else cfg.indent

    # Get input content
    try:
        content = get_input(input)
    except ValueError as e:
        typer.echo(f"Error: {e}", err=True)
        typer.echo("\nUsage examples:")
        typer.echo('  echo \'{"key": "value"}\' | pormat')
        typer.echo('  pormat \'{"key": "value"}\'')
        typer.echo("  cat data.json | pormat -f yaml")
        raise typer.Exit(1)

    content = content.strip()
    if not content:
        typer.echo("Error: Input is empty", err=True)
        raise typer.Exit(1)

    # Detect input format
    detected_format = detect_format(content)

    # Parse input
    parser_class = PARSERS.get(detected_format)
    if parser_class is None:
        typer.echo(f"Error: Unknown input format '{detected_format}'", err=True)
        raise typer.Exit(1)

    parser = parser_class()
    try:
        data = parser.parse(content)
    except Exception as e:
        typer.echo(f"Error parsing {detected_format.upper()}: {e}", err=True)
        raise typer.Exit(1)

    # Format output
    formatter_class = FORMATTERS.get(output_format)
    if formatter_class is None:
        typer.echo(f"Error: Unknown output format '{output_format}'", err=True)
        typer.echo("Available formats: json, yaml, python, toml")
        raise typer.Exit(1)

    formatter = formatter_class()
    try:
        output = formatter.format(data, indent=output_indent, compact=compact)
    except ValueError as e:
        typer.echo(f"Error formatting to {output_format.upper()}: {e}", err=True)
        raise typer.Exit(1)

    # Print result
    typer.echo(output)
