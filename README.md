# PingVoice Plugin for Claude Code

Add voice feedback to your Claude Code sessions! This plugin integrates [PingVoice](https://pingvoice.io) TTS (Text-to-Speech) into Claude Code, giving you audio notifications for session events and task completions.

## Features

- **Session Greeting** - Hear a personalized welcome when you start a Claude Code session
- **Input Notifications** - Get audio alerts when Claude needs your input
- **Subagent Completion** - Know when background tasks finish without watching the terminal
- **Speak Skill** - Invoke `/pingvoice:speak` to have Claude announce messages on demand
- **Task Summaries** - Claude announces what it accomplished after completing work (via output style)

Audio plays through your browser via the PingVoice Dashboard - no local TTS engine required!

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- [uv](https://docs.astral.sh/uv/) - Python package manager (handles dependencies automatically)
- A [PingVoice](https://pingvoice.io) account with an API key

## Installation

Add the marketplace and install the plugin:

```
/plugin marketplace add pingvoice/claude-code
```

```
/plugin install pingvoice@pingvoice
```

## Configuration

### Environment Variables

Set these in your shell environment or `.env` file:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PINGVOICE_API_KEY` | Yes | - | API token from PingVoice Dashboard |
| `PINGVOICE_USER_NAME` | No | - | Your name for personalized messages |
| `PINGVOICE_API_URL` | No | `http://localhost/api/tts` | TTS API endpoint URL |
| `PINGVOICE_API_VOICE_ID` | No | - | Voice: Kore, Puck, Zephyr, Charon, Fenrir, Aoede, Leda, Orus, Perseus |
| `PINGVOICE_ORIGIN` | No | - | Origin identifier (e.g., "Claude Code") |

### Example .env

```bash
# Required - Get your API key from the PingVoice Dashboard
PINGVOICE_API_KEY=your_api_key_here

# Optional - Your name for personalized greetings
PINGVOICE_USER_NAME=Chris

# Optional - Override API endpoint if self-hosting
# PINGVOICE_API_URL=http://localhost/api/tts

# Optional - Choose a voice
PINGVOICE_API_VOICE_ID=Kore

# Optional - Track request origin
PINGVOICE_ORIGIN=Claude Code
```

## Usage

### Automatic Hooks

Once installed, the plugin automatically triggers audio for:

- **Session Start** - "Hi [name], let's start coding."
- **Notification** - "Hey [name], I need your input."
- **Subagent Stop** - "Subagent complete."

### Speak Skill

Invoke the speak skill to have Claude announce something:

```
/pingvoice:speak Your task is complete!
```

### Output Style (Optional)

Enable the TTS Summary output style in your Claude Code settings to have Claude announce a summary at the end of every response.

## Customization

### Changing TTS Messages

Edit the message strings in the hook scripts:

- **Session greeting**: `pingvoice/scripts/session_start.py`
- **Input notification**: `pingvoice/scripts/notification.py`
- **Subagent completion**: `pingvoice/scripts/subagent_stop.py`

### Adding New Hooks

1. Create a new Python script in `pingvoice/scripts/`
2. Follow the pattern of existing scripts (consume stdin, call api_tts.py)
3. Register the hook in `pingvoice/hooks/hooks.json`

Available hook events:
- `SessionStart` - When a session begins
- `Notification` - When user input is needed
- `SubagentStop` - When a subagent task completes
- `Stop` - When Claude stops generating
- `PreToolUse` / `PostToolUse` - Before/after tool execution
- `UserPromptSubmit` - When user submits a prompt

### Voice Selection

Set `PINGVOICE_API_VOICE_ID` to one of:
- Kore, Puck, Zephyr, Charon, Fenrir, Aoede, Leda, Orus, Perseus

## Troubleshooting

### No Audio Playing

1. **Check your API key** - Ensure `PINGVOICE_API_KEY` is set correctly
2. **Open the PingVoice Dashboard** - Audio plays in the browser, make sure the dashboard tab is open
3. **Check the API URL** - If self-hosting, verify `PINGVOICE_API_URL` is correct
4. **Test manually**:
   ```bash
   uv run pingvoice/scripts/api_tts.py "Test message"
   ```

### "PINGVOICE_API_KEY not set" Error

Set the environment variable in your shell or `.env` file:

```bash
export PINGVOICE_API_KEY=your_api_key_here
```

### "Rate limit exceeded" Error

PingVoice has a rate limit of 10 requests per minute. If you're hitting this limit, consider:
- Disabling some hooks (e.g., `SubagentStop` if using many subagents)
- Spacing out your Claude Code sessions

### Hooks Not Firing

1. Verify the plugin is loaded: `claude plugins list`
2. Check that uv is installed: `uv --version`
3. Ensure scripts are executable

## How It Works

```
Claude Code Event (e.g., session start)
         ↓
Hook triggers (defined in hooks/hooks.json)
         ↓
Python script sends message to PingVoice API
         ↓
API queues the audio (responds with 202 Accepted)
         ↓
Audio plays in your browser via WebSocket
```

The system uses a **fire-and-forget** design - scripts send the TTS request and exit immediately, so they never block Claude Code.

## Acknowledgments

The TTS summary output style was inspired by [claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery) by [@disler](https://github.com/disler).

## License

MIT License - Feel free to modify and share!
