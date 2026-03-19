---
name: lv1-workflow-youtube-knowledge-capture
description: Use when the user wants the knowledge in a YouTube video distilled into a reliable summary, study notes, takeaways, or reusable memo. Trigger when a YouTube URL or video ID is provided, or when the user already has a YouTube transcript and wants the core ideas extracted from a talk, lecture, tutorial, interview, panel, or explainer.
---

# YouTube Knowledge Capture

Use this skill to turn a YouTube video into grounded knowledge notes instead of a vague recap. Prefer transcript-backed summaries, keep the output structured, and be explicit when captions are missing or weak.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv1-workflow-youtube-knowledge-capture.md](../../knowledge/setup-prd/lv1-workflow-youtube-knowledge-capture.md).

## Input Decision

1. If the user already provided a transcript or detailed notes, summarize that directly and skip transcript fetching.
2. Otherwise, if the user gave a YouTube URL or video ID, run `scripts/fetch_youtube_transcript.py` first to collect metadata plus captions.
3. If the helper script fails because captions are unavailable or the page format changed, tell the user exactly what failed and ask for a transcript or pasted browser transcript instead of pretending you watched the video.

## Transcript Fetch

- Run:

```bash
python3 ~/.codex/skills/lv1-workflow-youtube-knowledge-capture/scripts/fetch_youtube_transcript.py '<youtube-url>'
```

- Use `--language <code>` when the user wants a non-default caption language.
- Use `--format text` only when you need a quick plain-text transcript. Prefer JSON so you keep metadata, caption quality, and timestamped segments.
- Treat the script output as source material. Do not invent details that are not supported by the transcript or metadata.

## Summary Workflow

1. Read the title, channel, description, and transcript before summarizing.
2. Identify the core thesis first. Then extract the main ideas, examples, and practical takeaways.
3. Collapse repetitive intro, outro, sponsor spots, or housekeeping unless the user specifically wants a full outline.
4. Keep speaker claims distinct from your own inference. If you are inferring a lesson or implication, label it as an inference.
5. Call out caption quality issues, missing sections, or ambiguity when they materially affect confidence.

## Output Shape

- Use [references/summary-template.md](references/summary-template.md) as the default structure.
- Adapt the output shape when the user asks for something narrower, such as:
  - executive summary
  - study notes
  - action list
  - timestamped chapter outline
  - comparison against another video or article
- When the user asks to save the summary, write Markdown unless they asked for a different format.

## Grounding Rules

- Prefer transcript-backed summaries over title-based guesses.
- Quote sparingly and only when a short exact phrase matters.
- Preserve technical terms, acronyms, and named frameworks from the video.
- If captions are auto-generated, mention that in the caveats section when precision matters.
- If the video has no captions and the user does not provide a transcript, do not pretend to summarize the full knowledge content.

## Typical Requests

- "Summarize the lessons in this YouTube talk."
- "Watch this interview and pull out the key insights."
- "Turn this tutorial into study notes with timestamps."
- "Extract the action items from this lecture."
- "Use the transcript from this YouTube video to create a reusable knowledge memo."

## Resources

- `scripts/fetch_youtube_transcript.py`: pull transcript plus metadata from a public YouTube URL or ID with the Python standard library.
- `references/summary-template.md`: default shape for a grounded knowledge summary.
