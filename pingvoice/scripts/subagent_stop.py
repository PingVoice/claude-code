#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Subagent stop - announce completion."""

import subprocess
import sys
from pathlib import Path


def main():
    # Consume stdin (required by hook system)
    sys.stdin.read()

    # Announce completion
    tts_script = Path(__file__).parent / "api_tts.py"
    subprocess.run(
        ["uv", "run", str(tts_script), "Subagent complete."],
        capture_output=True,
        timeout=10
    )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
