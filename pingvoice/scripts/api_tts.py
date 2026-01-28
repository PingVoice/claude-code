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
    PINGVOICE_API_URL: Optional. API endpoint URL (default: http://localhost/api/tts)
    PINGVOICE_API_VOICE_ID: Optional. Voice to use (Kore, Puck, Zephyr, Charon, Fenrir, Aoede, Leda, Orus, Perseus)
    PINGVOICE_ORIGIN: Optional. Origin identifier for request tracking (e.g., "Claude Code")
"""

import os
import sys
from dotenv import load_dotenv


def main():
    # Load environment variables
    # Project .env overrides shell defaults when running as a Claude Code hook
    project_dir = os.getenv('CLAUDE_PROJECT_DIR')
    if project_dir:
        project_env = os.path.join(project_dir, '.env')
        load_dotenv(project_env, override=True)
    else:
        # Manual testing - load from current directory
        load_dotenv(override=True)

    # Get API token
    api_token = os.getenv('PINGVOICE_API_KEY')
    if not api_token:
        print("Error: PINGVOICE_API_KEY not set in environment")
        print("Generate a token from the Dashboard and add to .env:")
        print("PINGVOICE_API_KEY=your_token_here")
        sys.exit(1)

    # Get API URL (default to localhost)
    api_url = os.getenv('PINGVOICE_API_URL', 'http://localhost/api/tts')

    # Get optional voice ID
    voice_id = os.getenv('PINGVOICE_API_VOICE_ID')

    # Get optional origin identifier
    origin = os.getenv('PINGVOICE_ORIGIN')

    # Get message from command line arguments
    if len(sys.argv) > 1:
        # Check for --message flag
        if sys.argv[1] == '--message' and len(sys.argv) > 2:
            message = ' '.join(sys.argv[2:])
        else:
            message = ' '.join(sys.argv[1:])
    else:
        print("Usage: api_tts.py <message>")
        print("       api_tts.py --message <message>")
        sys.exit(1)

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
        sys.exit(1)
    except requests.exceptions.Timeout:
        print("Error: Request timed out")
        sys.exit(1)
    except ImportError:
        print("Error: requests package not installed")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
