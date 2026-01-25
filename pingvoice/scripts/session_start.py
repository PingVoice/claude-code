#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///
"""Session start - greet user with TTS."""

import os
import subprocess
import sys
from pathlib import Path
from dotenv import load_dotenv


def main():
    # Consume stdin (required by hook system)
    sys.stdin.read()

    # Load environment variables
    load_dotenv()

    # Get user name from environment (default to generic greeting)
    user_name = os.getenv('PINGVOICE_USER_NAME', '')
    if user_name:
        message = f"Hi {user_name}, let's start coding."
    else:
        message = "Hi there, let's start coding."

    # Announce greeting
    tts_script = Path(__file__).parent / "api_tts.py"
    subprocess.run(
        ["uv", "run", str(tts_script), message],
        capture_output=True,
        timeout=10
    )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
