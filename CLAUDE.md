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
```

No build/test/lint commands - this is a configuration-only project.

## Architecture

```
Claude Code Event → Hook (hooks.json) → Python script → PingVoice API → Browser audio
```

**Two-level structure:**
- Repo root (`.claude-plugin/marketplace.json`) - Marketplace manifest listing available plugins
- `pingvoice/` directory - The actual plugin with hooks, skills, and scripts

**Key files:**
- `pingvoice/hooks/hooks.json` - Registers hooks for SessionStart, Notification, SubagentStop
- `pingvoice/scripts/api_tts.py` - Core TTS client (requests + python-dotenv)
- `pingvoice/skills/speak/SKILL.md` - Skill definition for `/pingvoice:speak` command

## Hook Script Pattern

All hook scripts MUST follow this pattern to avoid blocking Claude Code:

```python
def main():
    sys.stdin.read()  # Required - consume stdin from hook system
    # ... do work ...

if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # Suppress all exceptions
    sys.exit(0)  # Always exit 0
```

## Environment Variables

`PINGVOICE_API_KEY` (required) - API authentication token

Optional: `PINGVOICE_USER_NAME`, `PINGVOICE_API_VOICE_ID`, `PINGVOICE_ORIGIN`

Per-project `.env` files override shell defaults (loaded via `CLAUDE_PROJECT_DIR`).

## Adding New Hooks

1. Create script in `pingvoice/scripts/` following the pattern above
2. Register in `pingvoice/hooks/hooks.json` using `${CLAUDE_PLUGIN_ROOT}` for paths:
   ```json
   "command": "uv run \"${CLAUDE_PLUGIN_ROOT}/scripts/your_script.py\""
   ```
3. Available events: SessionStart, Notification, SubagentStop, Stop, PreToolUse, PostToolUse, UserPromptSubmit
