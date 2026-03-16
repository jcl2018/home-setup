#!/usr/bin/env python3
"""Restore a portable Codex home snapshot from a local or remote-backed repo."""

from __future__ import annotations

import ast
import argparse
import hashlib
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

PLACEHOLDER = "__" + "HOME" + "__"
LITERAL_PLACEHOLDER = "__HOME" + "_TOKEN_LITERAL__"
EXPECTED_VERSION = 1
MANIFEST_NAME = "codex-home-manifest.toml"
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
TRANSIENT_NAMES = {".DS_Store"}
TRANSIENT_SUFFIXES = {".pyc", ".pyo"}
TRANSIENT_PARTS = {"__pycache__"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Preview or apply a portable Codex home snapshot restore.",
    )
    parser.add_argument("--source", required=True, help="Local snapshot repo path.")
    parser.add_argument("--remote", help="Optional git remote to clone or pull from.")
    parser.add_argument(
        "--pull",
        action="store_true",
        help="Run git pull --ff-only before previewing or applying.",
    )
    parser.add_argument(
        "--home-root",
        default=str(Path.home()),
        help="Override the target home root. Defaults to the current home directory.",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Apply the restore after previewing the plan.",
    )
    return parser.parse_args()


def resolve_home_root(raw_home_root: str) -> Path:
    home_root = Path(raw_home_root).expanduser().resolve()
    home_root.mkdir(parents=True, exist_ok=True)
    return home_root


def resolve_source_root(raw_source_root: str) -> Path:
    return Path(raw_source_root).expanduser().resolve()


def ensure_source_repo(source_root: Path, remote: str | None) -> None:
    if source_root.exists():
        return
    if not remote:
        raise SystemExit(f"Snapshot repo does not exist: {source_root}")
    source_root.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["git", "clone", remote, str(source_root)],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )


def maybe_pull_source_repo(source_root: Path, should_pull: bool) -> bool:
    if not should_pull:
        return False
    if not (source_root / ".git").exists():
        raise SystemExit(f"Cannot pull because {source_root} is not a git repo")
    subprocess.run(
        ["git", "-C", str(source_root), "pull", "--ff-only"],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return True


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


def walk_tree(home_root: Path, rel_root: Path) -> set[Path]:
    abs_root = home_root / rel_root
    if not abs_root.exists():
        return set()

    files: set[Path] = set()
    for path in abs_root.rglob("*"):
        rel_path = path.relative_to(home_root).as_posix()
        if path.is_symlink():
            raise SystemExit(f"Symlinks are not supported in the managed restore set: {rel_path}")
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
            raise SystemExit(f"Symlinks are not supported in the managed restore set: {rel_path}")
        if is_excluded_prefix(rel_path) or is_transient_path(rel_path):
            continue
        files.add(path)
    return files


def collect_existing_home_files(home_root: Path) -> set[str]:
    files: set[str] = set()
    direct_files = [
        home_root / "AGENTS.md",
        home_root / ".codex" / ".local-work" / "current.md",
        home_root / ".codex" / "config.toml",
    ]
    for path in direct_files:
        if path.exists():
            files.add(path.relative_to(home_root).as_posix())
    for path in walk_tree(home_root, Path(".codex/skills")):
        files.add(path.relative_to(home_root).as_posix())
    for path in walk_tree(home_root, Path(".codex/knowledge")):
        files.add(path.relative_to(home_root).as_posix())
    for path in walk_automation_toml(home_root):
        files.add(path.relative_to(home_root).as_posix())
    return files


def load_manifest(source_root: Path) -> dict[str, object]:
    manifest_path = source_root / MANIFEST_NAME
    if not manifest_path.exists():
        raise SystemExit(f"Snapshot manifest not found: {manifest_path}")
    data = parse_manifest_text(manifest_path.read_text(encoding="utf-8"))
    if data.get("version") != EXPECTED_VERSION:
        raise SystemExit(f"Unsupported manifest version: {data.get('version')}")
    if data.get("placeholder_token") != PLACEHOLDER:
        raise SystemExit(f"Unexpected placeholder token: {data.get('placeholder_token')}")
    files = data.get("files")
    if not isinstance(files, list) or not files:
        raise SystemExit("Manifest does not contain a valid [[files]] list")
    return data


def parse_manifest_text(text: str) -> dict[str, object]:
    data: dict[str, object] = {}
    file_entries: list[dict[str, object]] = []
    current_entry: dict[str, object] | None = None

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if line == "[[files]]":
            current_entry = {}
            file_entries.append(current_entry)
            continue
        if "=" not in line:
            raise SystemExit(f"Unsupported manifest line: {raw_line}")
        key, raw_value = [part.strip() for part in line.split("=", 1)]
        value = ast.literal_eval(raw_value)
        if current_entry is not None:
            current_entry[key] = value
        else:
            data[key] = value

    data["files"] = file_entries
    return data


def is_binary_data(raw_bytes: bytes) -> bool:
    if b"\x00" in raw_bytes:
        return True
    try:
        raw_bytes.decode("utf-8")
    except UnicodeDecodeError:
        return True
    return False


def sha256_hex(raw_bytes: bytes) -> str:
    return hashlib.sha256(raw_bytes).hexdigest()


def desired_bytes_for_entry(source_root: Path, home_root: Path, entry: dict[str, object]) -> bytes:
    rel_path = entry["path"]
    source_path = source_root / rel_path
    if not source_path.exists():
        raise SystemExit(f"Snapshot file listed in manifest is missing: {source_path}")
    raw_bytes = source_path.read_bytes()
    expected_hash = entry["sha256"]
    if sha256_hex(raw_bytes) != expected_hash:
        raise SystemExit(f"Snapshot file hash mismatch for {rel_path}")
    kind = entry["kind"]
    if kind == "binary":
        return raw_bytes
    if kind != "text":
        raise SystemExit(f"Unknown file kind in manifest for {rel_path}: {kind}")
    if is_binary_data(raw_bytes):
        raise SystemExit(f"Manifest marks {rel_path} as text but the file is not UTF-8 text")
    text = raw_bytes.decode("utf-8")
    text = text.replace(PLACEHOLDER, str(home_root))
    return text.replace(LITERAL_PLACEHOLDER, PLACEHOLDER).encode("utf-8")


def write_file(path: Path, raw_bytes: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(raw_bytes)


def backup_file(home_root: Path, backup_root: Path, rel_path: str) -> None:
    source_path = home_root / rel_path
    if not source_path.exists():
        return
    backup_path = backup_root / rel_path
    backup_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source_path, backup_path)


def prune_empty_dirs(root: Path, stop_at: Path) -> None:
    current = root
    while current != stop_at and current.exists():
        if any(current.iterdir()):
            break
        current.rmdir()
        current = current.parent


def render_backup_plan(adds: list[str], updates: list[str], deletes: list[str], source_root: Path) -> str:
    lines = [
        f"source = {source_root}",
        f"generated_at = {datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')}",
        "",
        f"adds = {len(adds)}",
        f"updates = {len(updates)}",
        f"deletes = {len(deletes)}",
        "",
    ]
    for label, paths in [("ADD", adds), ("UPDATE", updates), ("DELETE", deletes)]:
        for rel_path in paths:
            lines.append(f"{label} {rel_path}")
    return "\n".join(lines) + "\n"


def preview_changes(adds: list[str], updates: list[str], deletes: list[str]) -> None:
    print(f"Plan summary: {len(adds)} add, {len(updates)} update, {len(deletes)} delete")
    for label, paths in [("ADD", adds), ("UPDATE", updates), ("DELETE", deletes)]:
        for rel_path in paths:
            print(f"{label} {rel_path}")


def main() -> int:
    args = parse_args()
    home_root = resolve_home_root(args.home_root)
    source_root = resolve_source_root(args.source)
    source_missing_before = not source_root.exists()

    ensure_source_repo(source_root, args.remote)
    cloned = source_missing_before and bool(args.remote)
    pulled = maybe_pull_source_repo(source_root, args.pull)

    manifest = load_manifest(source_root)
    manifest_entries = manifest["files"]

    desired_files: dict[str, bytes] = {}
    for raw_entry in manifest_entries:
        if not isinstance(raw_entry, dict):
            raise SystemExit("Manifest file entries must be tables")
        rel_path = raw_entry.get("path")
        if not isinstance(rel_path, str):
            raise SystemExit("Manifest entry is missing a valid path")
        desired_files[rel_path] = desired_bytes_for_entry(source_root, home_root, raw_entry)

    existing_files = collect_existing_home_files(home_root)
    desired_paths = set(desired_files)

    adds: list[str] = []
    updates: list[str] = []
    deletes: list[str] = []

    for rel_path in sorted(desired_paths):
        target_path = home_root / rel_path
        if target_path.is_symlink():
            raise SystemExit(f"Refusing to overwrite symlink target: {target_path}")
        if not target_path.exists():
            adds.append(rel_path)
            continue
        if target_path.read_bytes() != desired_files[rel_path]:
            updates.append(rel_path)

    for rel_path in sorted(existing_files - desired_paths):
        target_path = home_root / rel_path
        if target_path.is_symlink():
            raise SystemExit(f"Refusing to delete symlink target: {target_path}")
        deletes.append(rel_path)

    if cloned:
        print(f"Cloned snapshot repo into {source_root}")
    if pulled:
        print(f"Pulled latest changes in {source_root}")

    preview_changes(adds, updates, deletes)
    if not args.apply:
        print("Preview only. Re-run with --apply after reviewing the plan.")
        return 0

    backup_root = (
        home_root
        / ".codex"
        / "restore_backups"
        / datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    )
    backup_root.mkdir(parents=True, exist_ok=True)
    write_file(
        backup_root / "restore-plan.txt",
        render_backup_plan(adds, updates, deletes, source_root).encode("utf-8"),
    )

    for rel_path in sorted(updates + deletes):
        backup_file(home_root, backup_root, rel_path)

    for rel_path in adds + updates:
        write_file(home_root / rel_path, desired_files[rel_path])

    for rel_path in deletes:
        target_path = home_root / rel_path
        if target_path.exists():
            target_path.unlink()
            prune_empty_dirs(target_path.parent, home_root)

    verified_files = collect_existing_home_files(home_root)
    if verified_files != desired_paths:
        raise SystemExit("Post-restore verification failed: managed file set does not match the snapshot")
    for rel_path in sorted(desired_paths):
        if (home_root / rel_path).read_bytes() != desired_files[rel_path]:
            raise SystemExit(f"Post-restore verification failed for {rel_path}")

    print(f"Applied restore into {home_root}")
    print(f"Backed up changed files to {backup_root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
