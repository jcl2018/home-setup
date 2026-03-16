#!/usr/bin/env python3
"""Export the Codex home control layer into a static local git mirror."""

from __future__ import annotations

import argparse
import hashlib
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

SNAPSHOT_VERSION = 3
MANAGED_ROOTS = [
    "AGENTS.md",
    ".codex/.local-work/current.md",
    ".codex/config.toml",
    ".codex/skills",
    ".codex/knowledge",
    ".codex/automations",
]
EXCLUDED_PATHS = [
    ".codex/.codex-global-state.json",
    ".codex/auth.json",
    ".codex/logs_1.sqlite",
    ".codex/logs_1.sqlite-shm",
    ".codex/logs_1.sqlite-wal",
    ".codex/memories",
    ".codex/models_cache.json",
    ".codex/restore_backups",
    ".codex/session_index.jsonl",
    ".codex/sessions",
    ".codex/shell_snapshots",
    ".codex/skills/.system",
    ".codex/sqlite",
    ".codex/state_5.sqlite",
    ".codex/state_5.sqlite-shm",
    ".codex/state_5.sqlite-wal",
    ".codex/tmp",
    ".codex/vendor_imports",
]
MANIFEST_NAME = "codex-home-manifest.toml"
README_NAME = "README.md"
TRANSIENT_NAMES = {".DS_Store"}
TRANSIENT_SUFFIXES = {".pyc", ".pyo", ".swo", ".swp", ".swx"}
TRANSIENT_PARTS = {"__pycache__"}
PORTABLE_HOME = "~"
HOST_SPECIFIC_TOP_LEVEL_TABLES = {"windows", "macos", "linux"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export the Codex home control layer into a static local git mirror.",
    )
    parser.add_argument("--repo", required=True, help="Target local git repo path.")
    parser.add_argument(
        "--home-root",
        default=str(Path.home()),
        help="Override the source home root. Defaults to the current home directory.",
    )
    return parser.parse_args()


def resolve_home_root(raw_home_root: str) -> Path:
    home_root = Path(raw_home_root).expanduser().resolve()
    if not home_root.exists():
        raise SystemExit(f"Home root does not exist: {home_root}")
    return home_root


def resolve_repo_root(raw_repo_root: str) -> Path:
    return Path(raw_repo_root).expanduser().resolve()


def ensure_repo_is_safe(home_root: Path, repo_root: Path) -> None:
    forbidden_roots = [
        home_root / ".codex" / "skills",
        home_root / ".codex" / "knowledge",
        home_root / ".codex" / "automations",
    ]
    for forbidden_root in forbidden_roots:
        try:
            repo_root.relative_to(forbidden_root)
        except ValueError:
            continue
        raise SystemExit(
            f"Refusing to export into {repo_root} because it lives inside managed path {forbidden_root}",
        )


def is_transient_path(rel_path: str) -> bool:
    path = Path(rel_path)
    if path.name in TRANSIENT_NAMES:
        return True
    if path.suffix in TRANSIENT_SUFFIXES:
        return True
    return any(part in TRANSIENT_PARTS for part in path.parts)


def is_excluded_prefix(rel_path: str) -> bool:
    for excluded in EXCLUDED_PATHS:
        if rel_path == excluded or rel_path.startswith(excluded + "/"):
            return True
    return False


def collect_home_files(home_root: Path) -> list[Path]:
    files: set[Path] = set()
    direct_files = [
        home_root / "AGENTS.md",
        home_root / ".codex" / ".local-work" / "current.md",
        home_root / ".codex" / "config.toml",
    ]
    for path in direct_files:
        if path.exists():
            files.add(path)

    files.update(walk_tree(home_root, Path(".codex/skills")))
    files.update(walk_tree(home_root, Path(".codex/knowledge")))
    files.update(walk_automation_toml(home_root))
    return sorted(files)


def walk_tree(home_root: Path, rel_root: Path) -> set[Path]:
    abs_root = home_root / rel_root
    if not abs_root.exists():
        return set()

    files: set[Path] = set()
    for path in abs_root.rglob("*"):
        rel_path = path.relative_to(home_root).as_posix()
        if path.is_symlink():
            raise SystemExit(f"Symlinks are not supported in the managed mirror: {rel_path}")
        if path.is_dir():
            continue
        if is_excluded_prefix(rel_path) or is_transient_path(rel_path):
            continue
        files.add(path)
    return files


def walk_automation_toml(home_root: Path) -> set[Path]:
    automations_root = home_root / ".codex" / "automations"
    if not automations_root.exists():
        return set()

    files: set[Path] = set()
    for path in automations_root.rglob("automation.toml"):
        rel_path = path.relative_to(home_root).as_posix()
        if path.is_symlink():
            raise SystemExit(f"Symlinks are not supported in the managed mirror: {rel_path}")
        if is_excluded_prefix(rel_path) or is_transient_path(rel_path):
            continue
        files.add(path)
    return files


def collect_repo_snapshot_files(repo_root: Path) -> set[str]:
    files: set[str] = set()
    for rel_path in collect_home_files(repo_root):
        files.add(rel_path.relative_to(repo_root).as_posix())
    return files


def is_binary_data(raw_bytes: bytes) -> bool:
    if b"\x00" in raw_bytes:
        return True
    try:
        raw_bytes.decode("utf-8")
    except UnicodeDecodeError:
        return True
    return False


def strip_host_specific_toml_tables(text: str) -> str:
    lines = text.splitlines(keepends=True)
    kept_lines: list[str] = []
    skipping = False

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            table_name = stripped[1:-1].strip()
            top_level_name = table_name.split(".", 1)[0]
            skipping = top_level_name in HOST_SPECIFIC_TOP_LEVEL_TABLES
            if skipping:
                continue
        if not skipping:
            kept_lines.append(line)

    return "".join(kept_lines).rstrip() + "\n"


def replace_home_root_with_portable_marker(text: str, home_root: Path) -> str:
    candidates = {str(home_root), home_root.as_posix()}
    for candidate in sorted((item for item in candidates if item), key=len, reverse=True):
        text = text.replace(candidate, PORTABLE_HOME)
    return text


def normalize_text_for_export(rel_path: str, text: str, home_root: Path) -> str:
    normalized = replace_home_root_with_portable_marker(text, home_root)
    if rel_path == ".codex/config.toml":
        normalized = strip_host_specific_toml_tables(normalized)
    return normalized


def transform_for_export(raw_bytes: bytes, rel_path: str, home_root: Path) -> tuple[bytes, str]:
    if is_binary_data(raw_bytes):
        return raw_bytes, "binary"
    normalized = normalize_text_for_export(rel_path, raw_bytes.decode("utf-8"), home_root)
    return normalized.encode("utf-8"), "text"


def sha256_hex(raw_bytes: bytes) -> str:
    return hashlib.sha256(raw_bytes).hexdigest()


def write_file(path: Path, raw_bytes: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(raw_bytes)


def prune_empty_dirs(root: Path, stop_at: Path) -> None:
    current = root
    while current != stop_at and current.exists():
        if any(current.iterdir()):
            break
        current.rmdir()
        current = current.parent


def ensure_git_repo(repo_root: Path) -> bool:
    repo_root.mkdir(parents=True, exist_ok=True)
    if (repo_root / ".git").exists():
        return False
    subprocess.run(
        ["git", "init", str(repo_root)],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return True


def render_toml_string(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def render_manifest(entries: list[dict[str, object]]) -> str:
    generated_at = (
        datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    )
    lines = [
        f"version = {SNAPSHOT_VERSION}",
        f"generated_at = {render_toml_string(generated_at)}",
        f"managed_roots = [{', '.join(render_toml_string(item) for item in MANAGED_ROOTS)}]",
        f"excluded_paths = [{', '.join(render_toml_string(item) for item in EXCLUDED_PATHS)}]",
        f"portable_home = {render_toml_string(PORTABLE_HOME)}",
        f"normalized_host_tables = [{', '.join(render_toml_string(item) for item in sorted(HOST_SPECIFIC_TOP_LEVEL_TABLES))}]",
        "",
    ]
    for entry in entries:
        lines.extend(
            [
                "[[files]]",
                f"path = {render_toml_string(entry['path'])}",
                f"kind = {render_toml_string(entry['kind'])}",
                f"sha256 = {render_toml_string(entry['sha256'])}",
                f"size = {entry['size']}",
                "",
            ]
        )
    return "\n".join(lines).rstrip() + "\n"


def render_readme() -> str:
    return f"""# Codex Home Settings

This repo stores a static mirror of a Codex home control layer.

## What it tracks

- `AGENTS.md`
- `.codex/.local-work/current.md`
- `.codex/config.toml`
- custom home skills under `.codex/skills/` except `.system`
- home knowledge under `.codex/knowledge/`, including workflow PRDs under `.codex/knowledge/setup-prd/`
- automation definitions at `.codex/automations/*/automation.toml`

## What it excludes

- auth and secret files such as `.codex/auth.json`
- sqlite state, logs, sessions, memories, caches, shell snapshots, and vendor imports
- automation runtime state outside `automation.toml`
- system-managed skills under `.codex/skills/.system`

## Mirror behavior

Managed files are exported from the current home tree within the tracked roots and exclusions listed in `codex-home-manifest.toml`.

For portability, mirrored text files normalize the source home root to `{PORTABLE_HOME}`, and mirrored `.codex/config.toml` omits top-level OS-specific tables such as `[windows]`, `[macos]`, and `[linux]`.

This repo intentionally does not include install or restore scripts.

## Layout guidance

Use this repo only for the Codex home control layer. Keep your normal coding repos outside this mirror repo under a stable workspace root such as `~/Documents/projects` or another single parent you control. Each project repo should keep its own `AGENTS.md`, verification commands, and repo-local AI docs.

## Export

```bash
python3 ~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo /path/to/this/repo
```
"""


def main() -> int:
    args = parse_args()
    home_root = resolve_home_root(args.home_root)
    repo_root = resolve_repo_root(args.repo)
    ensure_repo_is_safe(home_root, repo_root)

    repo_preexisted = repo_root.exists()
    git_initialized = ensure_git_repo(repo_root)

    source_files = collect_home_files(home_root)
    previous_snapshot_files = collect_repo_snapshot_files(repo_root)
    next_snapshot_files: set[str] = set()
    manifest_entries: list[dict[str, object]] = []

    for source_path in source_files:
        rel_path = source_path.relative_to(home_root).as_posix()
        raw_bytes = source_path.read_bytes()
        exported_bytes, kind = transform_for_export(raw_bytes, rel_path, home_root)
        write_file(repo_root / rel_path, exported_bytes)
        next_snapshot_files.add(rel_path)
        manifest_entries.append(
            {
                "path": rel_path,
                "kind": kind,
                "sha256": sha256_hex(exported_bytes),
                "size": len(exported_bytes),
            }
        )

    stale_files = sorted(previous_snapshot_files - next_snapshot_files)
    for rel_path in stale_files:
        stale_path = repo_root / rel_path
        if stale_path.exists():
            stale_path.unlink()
            prune_empty_dirs(stale_path.parent, repo_root)

    manifest_entries.sort(key=lambda item: str(item["path"]))
    write_file(repo_root / MANIFEST_NAME, render_manifest(manifest_entries).encode("utf-8"))
    write_file(repo_root / README_NAME, render_readme().encode("utf-8"))

    print(f"Exported {len(manifest_entries)} managed files into {repo_root}")
    print(f"Refreshed {MANIFEST_NAME} and {README_NAME}")
    if stale_files:
        print(f"Removed {len(stale_files)} stale managed files from the repo mirror")
    else:
        print("Removed 0 stale managed files from the repo mirror")
    if git_initialized:
        print("Initialized a git repo because the target folder did not already contain .git")
    else:
        print("Reused the existing git repo at the target path")
    if not repo_preexisted:
        print("Created the target folder before exporting the mirror")
    print("Next step: review README.md and git status, then commit or push only if desired")
    return 0


if __name__ == "__main__":
    sys.exit(main())
