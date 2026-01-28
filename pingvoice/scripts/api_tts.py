#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "requests",
#     "python-dotenv",
# ]
# ///

"""
API-based TTS Script

Sends text to the application's TTS API endpoint. Audio plays in the browser
Dashboard via WebSocket - this script is fire-and-forget.

Usage:
    ./api_tts.py "Your message here"
    ./api_tts.py --message "Your message here"

Environment Variables:
    PINGVOICE_API_KEY: Required. Your Sanctum API token for authentication.
    PINGVOICE_API_URL: Optional. API endpoint URL (default: https://pingvoice.io/api/notify)
    PINGVOICE_API_VOICE_ID: Optional. Voice to use (Kore, Puck, Zephyr, Charon, Fenrir, Aoede, Leda, Orus, Perseus)
    PINGVOICE_ORIGIN: Optional. Origin identifier for request tracking (e.g., "Claude Code")
"""

import os
import sys
from dotenv import load_dotenv


def main():
    # Project .env overrides shell defaults when running as a Claude Code hook
    project_dir = os.getenv('CLAUDE_PROJECT_DIR', '')
    env_path = os.path.join(project_dir, '.env') if project_dir else None
    load_dotenv(env_path, override=True)

    api_token = os.getenv('PINGVOICE_API_KEY')
    if not api_token:
        print("Error: PINGVOICE_API_KEY not set in environment")
        print("Generate a token from the Dashboard and add to .env:")
        print("PINGVOICE_API_KEY=your_token_here")
        sys.exit(1)

    api_url = os.getenv('PINGVOICE_API_URL', 'https://pingvoice.io/api/notify')
    voice_id = os.getenv('PINGVOICE_API_VOICE_ID')
    origin = os.getenv('PINGVOICE_ORIGIN')

    args = sys.argv[1:]
    if not args:
        print("Usage: api_tts.py <message>")
        print("       api_tts.py --message <message>")
        sys.exit(1)

    if args[0] == '--message':
        args = args[1:]
    message = ' '.join(args)

    try:
        import requests

        response = requests.post(
            api_url,
            headers={
                'Authorization': f'Bearer {api_token}',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
            },
            json={'message': message, 'voice_id': voice_id, 'origin': origin},
            timeout=10
        )

        if response.status_code == 202:
            data = response.json()
            print(f"Queued: {data.get('message_id', 'unknown')}")
            return
        elif response.status_code == 401:
            print("Error: Invalid or expired API token")
            sys.exit(1)
        elif response.status_code == 422:
            errors = response.json().get('errors', {})
            print(f"Validation error: {errors}")
            sys.exit(1)
        elif response.status_code == 429:
            print("Error: Rate limit exceeded (10 requests/minute)")
            sys.exit(1)
        else:
            print(f"Error: HTTP {response.status_code}")
            sys.exit(1)

    except requests.exceptions.ConnectionError:
        print("Error: Could not connect to API. Is the server running?")
    except requests.exceptions.Timeout:
        print("Error: Request timed out")
    except ImportError:
        print("Error: requests package not installed")
    except Exception as e:
        print(f"Error: {e}")
    sys.exit(1)


if __name__ == "__main__":
    main()
