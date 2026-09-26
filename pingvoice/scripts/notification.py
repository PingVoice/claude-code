#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Notification - tell user when input is needed."""

import os
import random
import subprocess
import sys
from pathlib import Path


def main():
    sys.stdin.read()

    user_name = os.getenv('PINGVOICE_USER_NAME', '')
    messages = [
        "I need your input.",
        "Quick question waiting for you.",
        "Paused here until you weigh in.",
        "Your call on this one.",
        "Standing by for your go-ahead.",
    ]
    if user_name:
        messages += [
            f"{user_name}, I need your input.",
            f"Got a question for you, {user_name}.",
            f"Over to you, {user_name}.",
        ]
    message = random.choice(messages)

    tts_script = Path(__file__).parent / "api_tts.py"
    subprocess.run(["uv", "run", str(tts_script), message], capture_output=True, timeout=10)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
