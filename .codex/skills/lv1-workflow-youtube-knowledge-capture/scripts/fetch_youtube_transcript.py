#!/usr/bin/env python3
"""Fetch YouTube metadata and captions with the Python standard library."""

from __future__ import annotations

import argparse
import html
import json
import re
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from typing import Any

USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0 Safari/537.36"
)
ANDROID_USER_AGENT = "com.google.android.youtube/20.10.38 (Linux; U; Android 14)"
ANDROID_CLIENT = {
    "clientName": "ANDROID",
    "clientVersion": "20.10.38",
}
API_KEY_PATTERNS = (
    r'"INNERTUBE_API_KEY":"([^"]+)"',
    r'"INNERTUBE_API_KEY":\s*"([^"]+)"',
)
VIDEO_ID_PATTERN = re.compile(r"^[A-Za-z0-9_-]{11}$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch YouTube metadata and transcript for a video URL or ID.",
    )
    parser.add_argument("video", help="YouTube URL or 11-character video ID.")
    parser.add_argument(
        "--language",
        default="en",
        help="Preferred caption language code. Defaults to en.",
    )
    parser.add_argument(
        "--format",
        choices=("json", "text"),
        default="json",
        help="Output format. Defaults to json.",
    )
    parser.add_argument(
        "--indent",
        type=int,
        default=2,
        help="JSON indentation level when --format json is used. Defaults to 2.",
    )
    return parser.parse_args()


def extract_video_id(value: str) -> str:
    raw = value.strip()
    if VIDEO_ID_PATTERN.fullmatch(raw):
        return raw

    parsed = urllib.parse.urlparse(raw)
    host = parsed.netloc.lower()
    path = parsed.path.strip("/")

    if host in {"youtu.be", "www.youtu.be"} and path:
        candidate = path.split("/", 1)[0]
        if VIDEO_ID_PATTERN.fullmatch(candidate):
            return candidate

    if host.endswith("youtube.com") or host.endswith("youtube-nocookie.com"):
        if path == "watch":
            candidate = urllib.parse.parse_qs(parsed.query).get("v", [""])[0]
            if VIDEO_ID_PATTERN.fullmatch(candidate):
                return candidate
        for prefix in ("embed/", "shorts/", "live/"):
            if path.startswith(prefix):
                candidate = path[len(prefix) :].split("/", 1)[0]
                if VIDEO_ID_PATTERN.fullmatch(candidate):
                    return candidate

    raise ValueError(f"Could not extract a valid YouTube video ID from: {value}")


def fetch_text(url: str, headers: dict[str, str] | None = None) -> str:
    request_headers = {"User-Agent": USER_AGENT}
    if headers:
        request_headers.update(headers)
    request = urllib.request.Request(url, headers=request_headers)
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8", "ignore")


def fetch_json(
    url: str,
    *,
    data: bytes | None = None,
    headers: dict[str, str] | None = None,
) -> dict[str, Any]:
    request_headers = {"User-Agent": USER_AGENT}
    if headers:
        request_headers.update(headers)
    request = urllib.request.Request(url, data=data, headers=request_headers)
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8", "ignore"))


def load_watch_page(video_id: str) -> str:
    return fetch_text(f"https://www.youtube.com/watch?v={video_id}")


def extract_api_key(html_text: str) -> str:
    for pattern in API_KEY_PATTERNS:
        match = re.search(pattern, html_text)
        if match:
            return match.group(1)
    raise RuntimeError("Could not find INNERTUBE_API_KEY in the YouTube watch page.")


def load_android_player_response(video_id: str, api_key: str) -> dict[str, Any]:
    # The watch page still exposes the API key, but the web caption URLs can return
    # empty bodies. Asking the Android player endpoint for caption tracks yields
    # transcript URLs that remain fetchable without third-party packages.
    payload = json.dumps(
        {
            "context": {"client": ANDROID_CLIENT},
            "videoId": video_id,
        }
    ).encode("utf-8")
    return fetch_json(
        f"https://www.youtube.com/youtubei/v1/player?key={api_key}&prettyPrint=false",
        data=payload,
        headers={
            "Content-Type": "application/json",
            "User-Agent": ANDROID_USER_AGENT,
        },
    )


def caption_tracks_from_player_response(player_response: dict[str, Any]) -> list[dict[str, Any]]:
    captions = player_response.get("captions") or {}
    renderer = captions.get("playerCaptionsTracklistRenderer") or {}
    return renderer.get("captionTracks") or []


def is_auto_generated(track: dict[str, Any]) -> bool:
    language_code = (track.get("languageCode") or "").lower()
    vss_id = (track.get("vssId") or "").lower()
    return track.get("kind") == "asr" or vss_id.startswith("a.") or language_code.endswith("-asr")


def choose_caption_track(
    tracks: list[dict[str, Any]],
    preferred_language: str,
) -> dict[str, Any]:
    if not tracks:
        raise RuntimeError("No caption tracks are available for this video.")

    preferred = preferred_language.lower()

    def score(track: dict[str, Any]) -> tuple[int, int, int, str]:
        language_code = (track.get("languageCode") or "").lower()
        exact = int(language_code == preferred)
        prefix = int(language_code.startswith(preferred) or preferred.startswith(language_code))
        english = int(language_code.startswith("en"))
        manual = int(not is_auto_generated(track))
        return (exact, prefix, english, manual, language_code)

    return sorted(tracks, key=score, reverse=True)[0]


def normalize_caption_text(raw_text: str) -> str:
    text = html.unescape(raw_text)
    text = text.replace("\n", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def format_timestamp(milliseconds: int) -> str:
    total_seconds = max(0, milliseconds // 1000)
    hours, remainder = divmod(total_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    if hours:
        return f"{hours:d}:{minutes:02d}:{seconds:02d}"
    return f"{minutes:02d}:{seconds:02d}"


def render_text_node(node: dict[str, Any] | None) -> str:
    if not node:
        return ""
    simple = node.get("simpleText")
    if simple:
        return simple
    runs = node.get("runs") or []
    return "".join((run.get("text") or "") for run in runs).strip()


def available_translation_languages(player_response: dict[str, Any]) -> set[str]:
    renderer = ((player_response.get("captions") or {}).get("playerCaptionsTracklistRenderer") or {})
    translation_languages = renderer.get("translationLanguages") or []
    return {
        (entry.get("languageCode") or "").lower()
        for entry in translation_languages
        if entry.get("languageCode")
    }


def with_query_param(url: str, key: str, value: str) -> str:
    parsed = urllib.parse.urlsplit(url)
    query_items = urllib.parse.parse_qsl(parsed.query, keep_blank_values=True)
    filtered_query = [(item_key, item_value) for item_key, item_value in query_items if item_key != key]
    filtered_query.append((key, value))
    return urllib.parse.urlunsplit(
        (
            parsed.scheme,
            parsed.netloc,
            parsed.path,
            urllib.parse.urlencode(filtered_query),
            parsed.fragment,
        )
    )


def prepare_caption_request(
    track: dict[str, Any],
    player_response: dict[str, Any],
    preferred_language: str,
) -> tuple[str, bool]:
    requested_language = preferred_language.lower()
    selected_language = (track.get("languageCode") or "").lower()
    can_translate = bool(track.get("isTranslatable"))

    if selected_language == requested_language or not requested_language:
        return track["baseUrl"], False

    if can_translate and requested_language in available_translation_languages(player_response):
        return with_query_param(track["baseUrl"], "tlang", requested_language), True

    return track["baseUrl"], False


def parse_caption_xml(track_url: str) -> tuple[list[dict[str, Any]], str]:
    xml_text = fetch_text(track_url, headers={"Referer": "https://www.youtube.com/"})
    if not xml_text.strip():
        raise RuntimeError("Caption track returned no data.")

    root = ET.fromstring(xml_text)
    segments: list[dict[str, Any]] = []
    previous_text = ""

    for paragraph in root.findall(".//p"):
        text = normalize_caption_text("".join(paragraph.itertext()))
        if not text or text == previous_text:
            continue
        previous_text = text
        start_ms = int(float(paragraph.attrib.get("t") or 0))
        duration_ms = int(float(paragraph.attrib.get("d") or 0))
        segments.append(
            {
                "start_ms": start_ms,
                "duration_ms": duration_ms,
                "start": format_timestamp(start_ms),
                "text": text,
            }
        )

    if not segments:
        raise RuntimeError("Caption track returned no transcript segments.")

    transcript = "\n".join(segment["text"] for segment in segments)
    return segments, transcript


def build_payload(video_input: str, preferred_language: str) -> dict[str, Any]:
    video_id = extract_video_id(video_input)
    watch_page_html = load_watch_page(video_id)
    api_key = extract_api_key(watch_page_html)
    player_response = load_android_player_response(video_id, api_key)
    playability_status = player_response.get("playabilityStatus") or {}
    if playability_status.get("status") not in {None, "OK"}:
        reason = playability_status.get("reason") or playability_status.get("status")
        raise RuntimeError(f"Video is not playable via the YouTube player endpoint: {reason}")
    video_details = player_response.get("videoDetails") or {}
    tracks = caption_tracks_from_player_response(player_response)
    selected_track = choose_caption_track(tracks, preferred_language)
    transcript_url, translated = prepare_caption_request(
        selected_track,
        player_response,
        preferred_language,
    )
    segments, transcript = parse_caption_xml(transcript_url)

    return {
        "video_id": video_id,
        "source_url": f"https://www.youtube.com/watch?v={video_id}",
        "title": video_details.get("title"),
        "channel": video_details.get("author"),
        "duration_seconds": int(video_details.get("lengthSeconds") or 0),
        "description": video_details.get("shortDescription") or "",
        "captions": {
            "requested_language": preferred_language,
            "language_code": selected_track.get("languageCode"),
            "language_name": render_text_node(selected_track.get("name")),
            "auto_generated": is_auto_generated(selected_track),
            "translated": translated,
            "track_count": len(tracks),
        },
        "transcript": transcript,
        "segments": segments,
    }


def render_text(payload: dict[str, Any]) -> str:
    lines = [
        f"Title: {payload.get('title') or ''}",
        f"Channel: {payload.get('channel') or ''}",
        f"URL: {payload.get('source_url') or ''}",
        f"Duration seconds: {payload.get('duration_seconds') or 0}",
        (
            "Captions: "
            f"{payload['captions'].get('language_code') or ''}"
            f"{' (auto)' if payload['captions'].get('auto_generated') else ''}"
        ),
        "",
        payload.get("transcript") or "",
    ]
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    args = parse_args()
    try:
        payload = build_payload(args.video, args.language)
    except Exception as exc:  # pragma: no cover - exercised by real script use
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    if args.format == "text":
        sys.stdout.write(render_text(payload))
        return 0

    json.dump(payload, sys.stdout, indent=args.indent)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
