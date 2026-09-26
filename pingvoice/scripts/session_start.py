#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Session start - greet user with TTS."""

import os
import random
import subprocess
import sys
from pathlib import Path


def main():
    sys.stdin.read()

    user_name = os.getenv('PINGVOICE_USER_NAME', '')
    messages = [
        "cheerful: Let's start coding.",
        "relaxed: Ready when you are.",
        "energetic: Fresh session, let's build something.",
        "playful: Terminal's warm. What are we making?",
        "upbeat: Back at it. What's first?",
    ]
    if user_name:
        messages += [
            f"cheerful: Hi {user_name}, let's start coding.",
            f"warm: Welcome back, {user_name}.",
            f"relaxed: {user_name}, ready when you are.",
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
