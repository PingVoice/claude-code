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
        "curious: I need your input.",
        "curious: Quick question waiting for you.",
        "patient: Paused here until you weigh in.",
        "thoughtful: Your call on this one.",
        "calm: Standing by for your go-ahead.",
    ]
    if user_name:
        messages += [
            f"polite: {user_name}, I need your input.",
            f"curious: Got a question for you, {user_name}.",
            f"friendly: Over to you, {user_name}.",
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
