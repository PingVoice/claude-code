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
        "curious: I've hit a question and need your input before going on.",
        "curious: There's a quick question waiting for you in the terminal.",
        "patient: I'm paused here until you get a chance to weigh in.",
        "thoughtful: This one is your call, so I'm waiting on you.",
        "calm: Standing by for your go-ahead whenever you're ready.",
    ]
    if user_name:
        messages += [
            f"polite: {user_name}, I need your input before I can keep going.",
            f"curious: I've got a question for you, {user_name}, whenever you have a moment.",
            f"friendly: Over to you, {user_name}. I need a decision to continue.",
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
