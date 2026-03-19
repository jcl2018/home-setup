# Lv1 Workflow YouTube Knowledge Capture PRD

## Purpose

Define the desired behavior for a reusable home skill that turns a YouTube video into a reliable knowledge summary by pulling transcript data, preserving the strongest ideas, and calling out uncertainty when captions are missing or weak.

## Desired State

- The skill triggers when the user provides a YouTube URL or video ID and wants a summary, notes, takeaways, lesson extraction, or knowledge capture from the video.
- The skill can also work from a transcript the user already provides when direct transcript retrieval is unavailable or unnecessary.
- The skill includes a deterministic helper script that fetches YouTube metadata and captions without depending on third-party Python packages.
- The skill prefers caption-backed summaries over vibes-based summaries from thumbnails or titles.
- The skill produces a structured output with a thesis, key ideas, supporting examples, practical takeaways, and caveats.
- The skill clearly reports when captions are unavailable, auto-generated, or low confidence.

## Audit Checklist

- The skill keeps the trigger description specific to YouTube summarization and transcript-backed knowledge capture.
- The helper script works on a real public YouTube URL with captions.
- The helper script fails clearly when a video has no captions or the watch page cannot be parsed.
- The `SKILL.md` stays lean and points to the summary template instead of duplicating it inline.
- The home PRD index includes the skill.

## Success Criteria

- Another Codex instance can use the skill on a YouTube URL and get enough metadata plus transcript text to write a solid knowledge summary.
- The skill reduces repeated transcript-fetch boilerplate and avoids relying on optional external packages.
- The final summary remains grounded in the available transcript instead of invented details.

## Out of Scope

- Downloading the video file or extracting frames.
- Replacing a full transcription service for videos with no accessible caption track.
- Producing a perfect chapterization for every video.

## Related Sources

- `~/.codex/skills/lv1-workflow-youtube-knowledge-capture/SKILL.md`
- `~/.codex/skills/lv1-workflow-youtube-knowledge-capture/scripts/fetch_youtube_transcript.py`
- `~/.codex/skills/lv1-workflow-youtube-knowledge-capture/references/summary-template.md`

## Last Checked

- 2026-03-18
