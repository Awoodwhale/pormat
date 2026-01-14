# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Development Setup
```bash
# Install dependencies and sync environment
uv sync

# Run the CLI tool
uv run pormat '{"key": "value"}'
```

### Testing
```bash
# Run all tests
./test.sh

# Run a specific test group (edit test.sh and run only that section)
```

### Type Checking / Linting
No linting or type checking is currently configured in this project.

## Architecture Overview

Pormat is a CLI tool for formatting and converting data between JSON, YAML, TOML, and Python literal formats. It uses a modular plugin architecture:

### Core Data Flow

```
Input (stdin/CLI arg) -> Load Config -> Detect Format -> Parse -> Format -> Output (stdout)
```

1. **Input**: `get_input()` in [utils/io.py](src/pormat/utils/io.py) reads from stdin or CLI argument
2. **Config**: `load_config()` in [config/loader.py](src/pormat/config/loader.py) searches multiple locations for config files
3. **Detection**: `detect_format()` in [detector.py](src/pormat/detector.py) tries parsers in order: JSON -> TOML -> YAML -> Python
4. **Parse**: Selected parser (from [parsers/](src/pormat/parsers/)) converts string to Python object
5. **Format**: Selected formatter (from [formatters/](src/pormat/formatters/)) converts Python object to output string

### Plugin Architecture

To add a new format, you need to create:
1. A parser class in `src/pormat/parsers/{format}_parser.py` with a static `parse(content: str) -> Any` method
2. A formatter class in `src/pormat/formatters/{format}_formatter.py` with a static `format(data: Any, indent: int, compact: bool) -> str` method
3. Update exports in `src/pormat/parsers/__init__.py` and `src/pormat/formatters/__init__.py`
4. Register in [cli.py](src/pormat/cli.py) by adding to `PARSERS` and `FORMATTERS` dicts
5. Add format to `FormatType` Literal type in [cli.py](src/pormat/cli.py), [config/loader.py](src/pormat/config/loader.py), [config/defaults.py](src/pormat/config/defaults.py), and [detector.py](src/pormat/detector.py)
6. Add detection logic to [detector.py](src/pormat/detector.py)

### Type System

The project uses `Literal` types for compile-time format validation:
- `FormatType = Literal["json", "yaml", "python", "toml"]`

When adding a new format, update this Literal in multiple files:
- [cli.py](src/pormat/cli.py:21)
- [config/loader.py](src/pormat/config/loader.py:13)
- [config/defaults.py](src/pormat/config/defaults.py:5)
- [detector.py](src/pormat/detector.py:5)

### Configuration Loading Order

The [config/loader.py](src/pormat/config/loader.py) searches for config files in this order:
1. Custom path (via `-c` option)
2. `./pormat.yml`, `./pormat.yaml`
3. `./pormat.toml`
4. `./pormat.json`
5. `.pormat.yml`, `.pormat.yaml`
6. `.pormat.toml`, `.pormat.json`
7. `.env` (with `PORMAT_` prefix, e.g., `PORMAT_FORMAT=yaml`)
8. `~/.config/pormat/config.yml`
9. `~/.pormat.yml`

Config keys: `default_format` and `default_indent`

### Important Implementation Details

- **Bytes handling**: JSON formatter's `_default()` method converts bytes to UTF-8 strings. Python parser handles byte literals using `ast.literal_eval()`
- **TOML limitations**: TOML only supports dict/object as root - arrays and primitives are rejected
- **Null handling**: JSON null is preserved in JSON/YAML, but filtered out in TOML (which lacks null support)
- **Compact mode**: JSON/YAML/Python support compact output; TOML ignores it (has fixed formatting)
- **Format detection**: YAML is a superset of JSON, so JSON is tried first to avoid false positives. Python literals with single quotes or `True`/`False`/`None` are distinguished from YAML

### File Structure

```
src/pormat/
├── __init__.py        # Entry point (main() function)
├── cli.py             # Typer CLI with FORMATTERS/PARSERS dicts
├── detector.py        # Auto-format detection with try-parse helpers
├── parsers/           # Input parsers (each has .parse() method)
├── formatters/        # Output formatters (each has .format() method)
├── config/
│   ├── defaults.py    # Default config values
│   └── loader.py      # Multi-location config file search
└── utils/
    └── io.py          # get_input() reads stdin/arg
```
