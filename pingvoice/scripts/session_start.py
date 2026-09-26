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
        "cheerful: A fresh session is up, so let's start coding.",
        "relaxed: All set up and ready to go whenever you are.",
        "energetic: New session, clean slate. Let's build something good today.",
        "playful: The terminal's all warmed up. So, what are we making?",
        "upbeat: Back at it again. What should we tackle first?",
    ]
    if user_name:
        messages += [
            f"cheerful: Hi {user_name}, the session is ready, so let's start coding.",
            f"warm: Welcome back, {user_name}. It's good to be working together again.",
            f"relaxed: {user_name}, everything's set up and ready whenever you are.",
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
