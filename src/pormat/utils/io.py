"""Input/output utility functions."""

import sys


def get_input(input_arg: str | None = None) -> str:
    """Get input from argument or stdin.

    Args:
        input_arg: Optional input string from command line argument.

    Returns:
        The input string.

    Raises:
        ValueError: If no input is provided.
    """
    if input_arg is not None:
        return input_arg

    # Check if input is being piped
    if not sys.stdin.isatty():
        return sys.stdin.read()

    raise ValueError("No input provided. Use pipe or provide INPUT argument.")
