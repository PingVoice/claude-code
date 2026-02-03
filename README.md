# PingVoice Plugin for Claude Code

Add voice feedback to your Claude Code sessions! This plugin integrates [PingVoice](https://pingvoice.io) TTS (Text-to-Speech) into Claude Code, giving you audio notifications for session events and task completions.

[![Watch the Video Tutorial](assets/pingvoice-claude-code-video-thumbnail.png)](https://www.youtube.com/watch?v=EsGWpLlOi0w)

## Quick Install

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/pingvoice/claude-code/master/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/pingvoice/claude-code/master/install.ps1 | iex
```

The installer will:
- Prompt for your PingVoice API key and validate it
- Ask for your name (for personalized greetings)
- Let you choose a voice
- Install the plugin and configure your shell
- Send a test message to confirm everything works

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

## Usage

### Automatic Hooks

Once installed, the plugin automatically triggers audio for:

- **Session Start** - "Hi [name], let's start coding."
- **Notification** - "Hey [name], I need your input."
- **Subagent Stop** - "Subagent complete."

### Output Style

Enable the TTS Summary output style to have Claude announce a summary at the end of every response.

1. Inside Claude Code, type `/output-style`
2. Select **pingvoice:TTS Summary** from the list

When enabled, Claude will speak a brief audio summary of what it accomplished after completing each task.

### Speak Skill

Invoke the speak skill to have Claude announce something:

```
/pingvoice:speak Your task is complete!
```

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PINGVOICE_API_KEY` | Yes | - | API token from PingVoice Dashboard |
| `PINGVOICE_USER_NAME` | No | - | Your name for personalized messages |
| `PINGVOICE_API_VOICE_ID` | No | - | Voice: Kore, Puck, Zephyr, Charon, Fenrir, Aoede, Leda, Orus, Perseus |
| `PINGVOICE_ORIGIN` | No | - | Origin identifier (e.g., "Claude Code") |

### Full Configuration Example

Update all desired variables to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
# Required - Get your API key from the PingVoice Dashboard
export PINGVOICE_API_KEY="your_api_key_here"

# Optional - Your name for personalized greetings
export PINGVOICE_USER_NAME=Chris

# Optional - Choose a voice
export PINGVOICE_API_VOICE_ID=Kore

# Optional - Track request origin
export PINGVOICE_ORIGIN="Claude Code"
```

After adding, run `source ~/.bashrc` (or `source ~/.zshrc`) or restart your terminal.

### Per-Project Overrides

Want a different voice or settings for different projects? Create a `.env` file in your project root:

```bash
# ~/my-project/.env
PINGVOICE_API_KEY=project_specific_key
PINGVOICE_API_VOICE_ID=Puck
PINGVOICE_USER_NAME=ProjectLead
```

**Important:** `.env` values always override shell environment variables. This means you can set defaults in your shell profile and override them per-project, or keep all configuration in `.env` files.

## Updating

Update the marketplace and plugin to the latest version:

```bash
claude plugin marketplace update pingvoice/claude-code
```

```bash
claude plugin update pingvoice@pingvoice
```

## Acknowledgments

The TTS summary output style was inspired by [claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery) by [@disler](https://github.com/disler).

## License

MIT License - Feel free to modify and share!
