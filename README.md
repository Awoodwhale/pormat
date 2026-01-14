# Pormat

A CLI tool to format and convert data (JSON/YAML/TOML/Python) in the terminal.

## Features

- **Auto-detection**: Automatically detects input format (JSON, YAML, TOML, or Python literals)
- **Format conversion**: Convert between JSON, YAML, TOML, and Python formats
- **Compact mode**: Output compact single-line format with `-C` flag
- **Configurable**: Support for configuration files and CLI options
- **Pipe-friendly**: Works seamlessly with stdin/stdout for Unix pipeline integration

## Installation

```bash
pip install pormat
```

Or using uv:

```bash
uv pip install pormat
```

## Usage

### Basic Usage

Format input from stdin:

```bash
echo '{"name": "John", "age": 30}' | pormat
```

Format input as argument:

```bash
pormat '{"name": "John", "age": 30}'
```

Convert to different format:

```bash
echo '{"name": "John", "age": 30}' | pormat -f yaml
```

### Compact Mode

Output compact single-line format:

```bash
echo '{"name": "John", "age": 30}' | pormat --compact
# Output: {"name":"John","age":30}

echo '{"name": "John", "age": 30}' | pormat -C -f yaml
# Output: {name: John, age: 30}
```

### Custom Indentation

```bash
echo '{"name": "John", "age": 30}' | pormat -i 2
```

### Reading from Files

```bash
cat data.json | pormat -f yaml
pormat -f python < data.json
```

### Format Conversion Examples

JSON to YAML:

```bash
echo '{"users": [{"name": "Alice"}, {"name": "Bob"}]}' | pormat -f yaml
```

YAML to JSON:

```bash
echo '- name: Alice
  - name: Bob' | pormat
```

Python dict to JSON:

```bash
echo "{'name': 'John', 'age': 30}" | pormat -f json
```

JSON to TOML:

```bash
echo '{"name": "pormat", "version": "1.0"}' | pormat -f toml
# Output:
# name = "pormat"
# version = "1.0"
```

TOML to YAML:

```bash
cat Cargo.toml | pormat -f yaml
```

TOML to JSON:

```bash
echo '[package]
name = "myapp"
version = "0.1.0"' | pormat -f json
# Output:
# {
#     "package": {
#         "name": "myapp",
#         "version": "0.1.0"
#     }
# }
```

## Configuration

Pormat supports configuration files in multiple formats. Create a configuration file in your project directory or home directory.

### Configuration File Locations (searched in order)

1. Custom path (with `-c` option)
2. `./pormat.yml`, `./pormat.yaml`
3. `./pormat.toml`
4. `./pormat.json`
5. `.pormat.yml`, `.pormat.yaml`
6. `.pormat.toml`, `.pormat.json`
7. `.env` (with `PORMAT_` prefix)
8. `~/.config/pormat/config.yml`
9. `~/.pormat.yml`

### YAML Configuration

```yaml
# pormat.yml
default_format: yaml
default_indent: 2
```

### TOML Configuration

```toml
# pormat.toml
default_format = "yaml"
default_indent = 2
```

### JSON Configuration

```json
{
  "default_format": "yaml",
  "default_indent": 2
}
```

### Environment Variables

```bash
# .env
PORMAT_FORMAT=yaml
PORMAT_INDENT=2
```

### Using Custom Config

```bash
pormat -c /path/to/config.yml '{"key": "value"}'
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--format` | `-f` | Output format: json, yaml, toml, python |
| `--indent` | `-i` | Indentation spaces (default: 4) |
| `--compact` | `-C` | Output compact single-line format |
| `--config` | `-c` | Custom config file path |
| `--help` | | Show help message |

## Real-World Examples

### API Response Formatting

```bash
# Pretty-print JSON from API
curl -s https://api.github.com/users/github | pormat

# Convert API response to YAML
curl -s https://api.github.com/users/github | pormat -f yaml -i 2

# Convert API response to TOML
curl -s https://api.github.com/repos/python/cpython | pormat -f toml > repo.toml
```

### Configuration File Conversion

```bash
# Convert pyproject.toml to YAML
cat pyproject.toml | pormat -f yaml

# Convert package.json to TOML
cat package.json | pormat -f toml

# Convert Docker Compose YAML to JSON
cat docker-compose.yml | pormat -f json
```

### Data Processing

```bash
# Compact JSON for storage
echo '{"large": "data", "here": true}' | pormat -C > compact.json

# Pipeline with jq
cat data.yaml | pormat -f json -C | jq '.key'

# Extract specific fields from TOML
cat Cargo.toml | pormat -f json | jq '.package.name'
```

### Multi-Format Workflows

```bash
# Python config to TOML
echo "{'database': {'host': 'localhost', 'port': 5432}}" | pormat -f toml

# YAML to Python literal
cat config.yml | pormat -f python

# TOML to Python literal
cat pyproject.toml | pormat -f python
```

### File Comparison

```bash
# Compare JSON and YAML files by converting to same format
diff <(cat file1.json | pormat -f yaml) <(cat file2.yaml | pormat -f yaml)
```

## Architecture

Pormat is built with a modular, plugin-based architecture that makes it easy to extend and maintain.

### Core Components

```
pormat/
├── cli.py              # Command-line interface (Typer)
├── detector.py         # Auto-format detection
├── parsers/            # Input format parsers
│   ├── json_parser.py
│   ├── yaml_parser.py
│   ├── toml_parser.py
│   └── python_parser.py
├── formatters/         # Output format formatters
│   ├── json_formatter.py
│   ├── yaml_formatter.py
│   ├── toml_formatter.py
│   └── python_formatter.py
├── config/             # Configuration management
│   ├── defaults.py
│   └── loader.py
└── utils/              # Utility functions
    └── io.py
```

### Data Flow

```
Input (stdin/arg)
    ↓
Load Configuration
    ↓
Detect Format (detector.py)
    ↓
Parse Input (parsers/*)
    ↓
Python Object
    ↓
Format Output (formatters/*)
    ↓
Output (stdout)
```

### Key Design Principles

1. **Separation of Concerns**: Parsing, formatting, and detection are independent modules
2. **Plugin Architecture**: Adding a new format only requires two files (parser + formatter)
3. **Type Safety**: Uses `Literal` types for compile-time format validation
4. **Error Handling**: Graceful fallbacks with clear error messages

## Development

### Adding a New Format

To add support for a new format (e.g., XML), follow these steps:

#### 1. Create the Parser

Create `src/pormat/parsers/xml_parser.py`:

```python
"""XML parser."""

from typing import Any

class XmlParser:
    """Parser for XML format."""

    @staticmethod
    def parse(content: str) -> Any:
        """Parse XML content.

        Args:
            content: The XML string to parse.

        Returns:
            The parsed Python object (dict).

        Raises:
            ValueError: If content is not valid XML.
        """
        # Import your XML library here
        import xmltodict

        try:
            return xmltodict.parse(content)
        except Exception as e:
            raise ValueError(f"Invalid XML: {e}")
```

#### 2. Create the Formatter

Create `src/pormat/formatters/xml_formatter.py`:

```python
"""XML formatter."""

from typing import Any

class XmlFormatter:
    """Formatter for XML output."""

    @staticmethod
    def format(data: Any, indent: int = 4, compact: bool = False) -> str:
        """Format data as XML.

        Args:
            data: The data to format (must be a dict).
            indent: Indentation spaces.
            compact: If True, output compact format.

        Returns:
            Formatted XML string.
        """
        import xmltodict

        if compact:
            return xmltodict.unparse(data, pretty=False)
        return xmltodict.unparse(data, pretty=True, indent=" " * indent)
```

#### 3. Update Exports

Update `src/pormat/parsers/__init__.py`:

```python
from pormat.parsers.xml_parser import XmlParser

__all__ = ["JsonParser", "YamlParser", "TomlParser", "PythonParser", "XmlParser"]
```

Update `src/pormat/formatters/__init__.py`:

```python
from pormat.formatters.xml_formatter import XmlFormatter

__all__ = ["JsonFormatter", "YamlFormatter", "TomlFormatter", "PythonFormatter", "XmlFormatter"]
```

#### 4. Register in CLI

Update `src/pormat/cli.py`:

```python
from pormat.parsers.xml_parser import XmlParser
from pormat.formatters.xml_formatter import XmlFormatter

FormatType = Literal["json", "yaml", "toml", "python", "xml"]

FORMATTERS = {
    "json": JsonFormatter,
    "yaml": YamlFormatter,
    "toml": TomlFormatter,
    "python": PythonFormatter,
    "xml": XmlFormatter,  # Add this
}

PARSERS = {
    "json": JsonParser,
    "yaml": YamlParser,
    "toml": TomlParser,
    "python": PythonParser,
    "xml": XmlParser,  # Add this
}
```

#### 5. Update Type Definitions

Update `src/pormat/config/defaults.py`:

```python
DEFAULT_FORMAT: Literal["json", "yaml", "toml", "python", "xml"] = "json"
```

Update `src/pormat/config/loader.py`:

```python
FormatType = Literal["json", "yaml", "toml", "python", "xml"]
```

Update `src/pormat/detector.py`:

```python
FormatType = Literal["json", "yaml", "toml", "python", "xml"]

def detect_format(content: str) -> FormatType:
    # ... existing detection logic ...

    # Add XML detection
    if _try_parse_xml(content):
        return "xml"

    # ... rest of function ...

def _try_parse_xml(content: str) -> bool:
    """Try to parse content as XML."""
    import xmltodict
    try:
        xmltodict.parse(content)
        return True
    except Exception:
        return False
```

#### 6. Add Dependencies

Update `pyproject.toml`:

```toml
dependencies = [
    "typer>=0.12.0",
    "pyyaml>=6.0",
    "tomli>=2.0",
    "tomli-w>=1.0",
    "python-dotenv>=1.0",
    "xmltodict>=0.13.0",  # Add your library
]
```

#### 7. Test

```bash
uv sync
echo '<root><name>test</name></root>' | uv run pormat -f json
```

### Running Tests

```bash
./test.sh
```

### Development Setup

```bash
# Clone the repository
git clone <repository-url>
cd pormat

# Install with uv (recommended)
uv sync

# Or with pip
pip install -e .

# Run tests
./test.sh

# Run the tool
uv run pormat '{"key": "value"}'
```

## License

MIT
