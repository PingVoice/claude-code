# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PingVoice is a Claude Code plugin marketplace that provides text-to-speech audio feedback via the PingVoice API. Audio plays through the browser (PingVoice Dashboard) - no local TTS engine required.

**Key Design Principle:** Fire-and-forget - all hooks send TTS requests and exit immediately, never blocking Claude Code.

## Commands

```bash
# Test TTS manually
uv run pingvoice/scripts/api_tts.py "Test message"

# Test plugin loading (from repo root)
claude --plugin-dir pingvoice

# Claude Code hooks are triggered automatically via pingvoice/hooks/hooks.json
# No build/test/lint commands - this is a configuration-only project
```

## Architecture

```
Claude Code Event → Hook (hooks.json) → Python script → PingVoice API → Browser audio
```

### Marketplace Structure

```
pingvoice-claude-code-hooks/        ← Repo root is the marketplace
├── .claude-plugin/
│   └── marketplace.json            # Marketplace manifest
├── pingvoice/                      ← Plugin directory
│   ├── .claude-plugin/
│   │   └── plugin.json             # Plugin manifest
│   ├── skills/
│   │   └── speak/
│   │       └── SKILL.md            # Claude-invocable TTS skill
│   ├── hooks/
│   │   └── hooks.json              # Hook registrations
│   ├── output-styles/
│   │   └── tts-summary.md          # Optional output style
│   ├── scripts/
│   │   ├── api_tts.py              # Core TTS API client
│   │   ├── session_start.py        # SessionStart hook script
│   │   ├── notification.py         # Notification hook script
│   │   └── subagent_stop.py        # SubagentStop hook script
│   └── .env.example                # Environment template
└── README.md
```

### Core Components

- **`.claude-plugin/marketplace.json`** - Marketplace manifest defining available plugins
- **`pingvoice/.claude-plugin/plugin.json`** - Plugin manifest with name, version, author
- **`pingvoice/hooks/hooks.json`** - Registers hooks for SessionStart, Notification, SubagentStop
- **`pingvoice/skills/speak/SKILL.md`** - Skill definition for `/pingvoice:speak` command
- **`pingvoice/scripts/api_tts.py`** - Core TTS client (requests + python-dotenv), handles API auth/errors
- **Hook scripts** (`session_start.py`, `notification.py`, `subagent_stop.py`) - Consume stdin (required by hook system), call api_tts.py, suppress all exceptions to prevent disruption

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `PINGVOICE_API_KEY` | Yes | API authentication token |
| `PINGVOICE_USER_NAME` | No | User's name for personalized messages |
| `PINGVOICE_API_URL` | No | Override API endpoint (default: `http://localhost/api/tts`) |
| `PINGVOICE_API_VOICE_ID` | No | Voice selection (Kore, Puck, Zephyr, Charon, Fenrir, Aoede, Leda, Orus, Perseus) |
| `PINGVOICE_ORIGIN` | No | Request origin identifier |

### Hook Events Used

- `SessionStart` - Greeting when session begins
- `Notification` - Alert when user input needed
- `SubagentStop` - Announcement when subagent completes

### Technical Details

- Python >=3.8 for api_tts.py, >=3.11 for hook scripts
- Uses uv inline script format (dependencies declared in script headers)
- All hooks exit with code 0 even on error (non-blocking requirement)
- API rate limit: 10 requests/minute
- User name personalization via `PINGVOICE_USER_NAME` env var

## Customization

- **TTS messages**: Edit the hook scripts in `pingvoice/scripts/`
- **Add hooks**: Create script in `pingvoice/scripts/`, register in `pingvoice/hooks/hooks.json`
- **Disable features**: Remove entries from `pingvoice/hooks/hooks.json`
