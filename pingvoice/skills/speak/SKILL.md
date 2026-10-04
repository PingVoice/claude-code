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
uv run "<resolved_script_path>" "<emotion>: <message>"
```

Start the message with an emotion prefix, e.g. `excited: All forty tests pass!`. The voice performs the emotion instead of reading it aloud, but only when a full sentence follows it (six or more words). After just a few words, it reads the emotion aloud.

## Message Guidelines

- Keep messages under 25 words (not counting the emotion prefix), unless the active output style sets a different length (the TTS Summary style allows up to three sentences, about 50 words)
- Pick an emotion that fits the moment: pleased or cheerful for routine work, excited or proud for big wins, playful for light moments, apologetic or calm for failures, curious when you need input
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

After running the command, continue with your response. **Never replace your answer with a confirmation.** If you were in the middle of answering the user, your next message must contain the full answer, ending with:

```
---
🔊 "<the full message that was sent>"
```

If the user invoked `/pingvoice:speak` directly and there is nothing else to say, the 🔊 line alone is fine.

Do NOT add commentary like "queued for playback" or "audio sent".
