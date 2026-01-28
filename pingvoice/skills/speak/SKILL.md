---
name: speak
description: Speak a message aloud via PingVoice TTS. Use after completing coding tasks to announce what you accomplished, when summarizing work you've done, or when the user asks to hear something spoken.
allowed-tools: Bash(uv run:*)
argument-hint: [message]
---

# Voice Announcement

Speak a message to the user using PingVoice text-to-speech. Audio plays in their browser via the PingVoice Dashboard.

## Command

The skill base directory shown above is `<plugin>/skills/speak`. The TTS script is at `<plugin>/scripts/api_tts.py`.

**Derive the script path** from the base directory by going up two levels and into scripts:
- Base directory: (shown in "Base directory for this skill" above)
- Script path: `<base_directory>/../../scripts/api_tts.py`

Run this to speak (replace the path with the resolved absolute path):
```bash
uv run "<resolved_script_path>" "<message>"
```

## Message Guidelines

- Keep messages under 25 words
- Address the user directly with warmth
- Focus on outcomes ("You're all set", "I've got you covered")
- Be conversational, not robotic
- No pet names (darling, love, babe, etc.)

## When to Use

- After completing a coding task
- When summarizing what you accomplished
- When the user explicitly asks to hear something
- After significant milestones in a session

## Response Format

After running the command, respond with ONLY:

```
🔊 "<the full message that was sent>"
```

Do NOT add any additional commentary like "queued for playback" or "audio sent". The speaker emoji and quoted message is sufficient confirmation.
