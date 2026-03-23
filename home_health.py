#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Optional, Tuple


ALLOWED_HOSTS = {"claude", "codex"}
ALLOWED_SCOPES = {"repo-owned", "backup-only"}
REQUIRED_ITEM_KEYS = {"id", "label", "repo_path", "live_path", "sync_scope"}
REQUIRED_SPECIAL_ASSET_KEYS = {"category", "label", "repo_path", "summary"}
CODE_ROOT = Path(__file__).resolve().parent


def repo_root() -> Path:
    override = os.environ.get("HOME_SETUP_REPO_ROOT")
    if override:
        return Path(override).expanduser().resolve()
    return Path(__file__).resolve().parent


def home_paths() -> dict:
    home_dir = Path(os.environ.get("HOME", str(Path.home()))).expanduser()
    return {
        "home": home_dir,
        "claude_home": Path(os.environ.get("HOME_SETUP_CLAUDE_HOME", str(home_dir / ".claude"))).expanduser(),
        "codex_home": Path(os.environ.get("HOME_SETUP_CODEX_HOME", str(home_dir / ".codex"))).expanduser(),
        "codex_agents": Path(os.environ.get("HOME_SETUP_CODEX_AGENTS", str(home_dir / "AGENTS.md"))).expanduser(),
        "gstack_state_dir": Path(os.environ.get("HOME_SETUP_GSTACK_STATE_DIR", str(home_dir / ".gstack"))).expanduser(),
    }


def expand_live_path(raw_path: str, paths: dict) -> Path:
    if raw_path == "~/AGENTS.md":
        return paths["codex_agents"]
    if raw_path.startswith("~/.claude"):
        return paths["claude_home"] / raw_path[len("~/.claude/") :] if raw_path != "~/.claude" else paths["claude_home"]
    if raw_path.startswith("~/.codex"):
        return paths["codex_home"] / raw_path[len("~/.codex/") :] if raw_path != "~/.codex" else paths["codex_home"]
    if raw_path.startswith("~/"):
        return paths["home"] / raw_path[2:]
    return Path(raw_path)


def run_command(cmd, *, cwd=None, env=None, timeout=15):
    return subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        env=env,
        capture_output=True,
        text=True,
        timeout=timeout,
    )


def run_sync(command: str, *, host: str, scope: Optional[str] = None, fmt: Optional[str] = None, env=None) -> subprocess.CompletedProcess:
    cmd = [str(CODE_ROOT / "sync.sh"), command, "--host", host]
    if scope:
        cmd.extend(["--scope", scope])
    if fmt:
        cmd.extend(["--format", fmt])
    completed = run_command(cmd, cwd=repo_root(), env=env)
    if completed.returncode != 0:
        raise RuntimeError(
            f"sync.sh {' '.join(cmd[1:])} failed\nstdout:\n{completed.stdout}\nstderr:\n{completed.stderr}"
        )
    return completed


def load_inventory(host: str) -> dict:
    path = repo_root() / "home-inventory.json"
    data = json.loads(path.read_text())

    if host not in data:
        raise ValueError(f"inventory missing host section: {host}")

    section = data[host]
    for key in ("tracked_upstreams", "customized_by_me", "backup_only_personal_state"):
        if key not in section or not isinstance(section[key], list):
            raise ValueError(f"inventory[{host!r}] missing list: {key}")
    if "special_assets" in section and not isinstance(section["special_assets"], list):
        raise ValueError(f"inventory[{host!r}] special_assets must be a list")

    seen_ids = set()
    for key in ("tracked_upstreams", "customized_by_me", "backup_only_personal_state"):
        for item in section[key]:
            missing = REQUIRED_ITEM_KEYS - set(item)
            if missing:
                raise ValueError(f"inventory item missing keys {sorted(missing)}: {item}")
            if item["sync_scope"] not in ALLOWED_SCOPES:
                raise ValueError(f"inventory item has invalid sync_scope: {item['sync_scope']}")
            if item["id"] in seen_ids:
                raise ValueError(f"inventory item id is duplicated: {item['id']}")
            seen_ids.add(item["id"])

    for asset in section.get("special_assets", []):
        missing = REQUIRED_SPECIAL_ASSET_KEYS - set(asset)
        if missing:
            raise ValueError(f"inventory special asset missing keys {sorted(missing)}: {asset}")

    return section


def status_by_id(host: str, env) -> dict:
    completed = run_sync("status", host=host, fmt="json", env=env)
    payload = json.loads(completed.stdout)
    return {item["id"]: item for item in payload["items"]}


def git_stdout(args: list[str], *, check=True) -> str:
    completed = run_command(["git", *args], cwd=repo_root())
    if check and completed.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed: {completed.stderr.strip()}")
    return completed.stdout.strip()


def git_has_ref(ref: str) -> bool:
    completed = run_command(["git", "rev-parse", "--verify", "--quiet", ref], cwd=repo_root())
    return completed.returncode == 0


def evaluate_safe_push_gate(host: str, customizations: list[dict], env) -> dict:
    reasons = []
    checks = []

    runtime_host = env.get("HOME_SETUP_RUNTIME_HOST")
    runtime_host_ok = not runtime_host or runtime_host == host
    checks.append(
        {
            "name": "host_match",
            "ok": runtime_host_ok,
            "detail": f"runtime_host={runtime_host or 'unset'} target_host={host}",
        }
    )
    if not runtime_host_ok:
        reasons.append("host_mismatch")

    try:
        branch = git_stdout(["branch", "--show-current"])
    except RuntimeError:
        branch = ""
    branch_ok = branch == "main"
    checks.append({"name": "branch_main", "ok": branch_ok, "detail": f"branch={branch or 'unknown'}"})
    if not branch_ok:
        reasons.append("wrong_branch")

    repo_owned_paths = [item["repo_path"] for item in customizations]
    if repo_owned_paths:
        status_completed = run_command(
            ["git", "status", "--porcelain", "--untracked-files=no", "--", *repo_owned_paths],
            cwd=repo_root(),
        )
        dirty = status_completed.returncode == 0 and bool(status_completed.stdout.strip())
        checks.append(
            {
                "name": "repo_owned_clean",
                "ok": not dirty,
                "detail": "repo-owned files are clean" if not dirty else status_completed.stdout.strip().replace("\n", "; "),
            }
        )
        if dirty:
            reasons.append("dirty_worktree")

        baseline_ref = "origin/main" if git_has_ref("origin/main") else "HEAD"
        if baseline_ref != "HEAD":
            diff_completed = run_command(
                ["git", "diff", "--quiet", baseline_ref, "--", *repo_owned_paths],
                cwd=repo_root(),
            )
            baseline_ok = diff_completed.returncode == 0
            baseline_detail = f"baseline_ref={baseline_ref}"
            if diff_completed.returncode == 1:
                baseline_detail = f"{baseline_detail} drift_detected"
                reasons.append("baseline_drift")
            elif diff_completed.returncode not in (0, 1):
                baseline_ok = False
                baseline_detail = f"{baseline_detail} comparison_failed"
                reasons.append("baseline_unknown")
            checks.append({"name": "baseline_match", "ok": baseline_ok, "detail": baseline_detail})
        else:
            checks.append({"name": "baseline_match", "ok": True, "detail": "baseline_ref=HEAD"})

    paths = home_paths()
    missing_live_items = []
    for item in customizations:
        live_path = expand_live_path(item["live_path"], paths)
        if not live_path.exists() and not item.get("allow_create", False):
            missing_live_items.append(f"{item['id']}:{live_path}")
            reasons.append(f"unexpected_missing_live:{item['id']}")
    checks.append(
        {
            "name": "live_targets_present",
            "ok": not missing_live_items,
            "detail": "all expected live targets present"
            if not missing_live_items
            else "; ".join(missing_live_items),
        }
    )

    deduped = []
    for reason in reasons:
        if reason not in deduped:
            deduped.append(reason)

    return {"allowed": not deduped, "reasons": deduped, "checks": checks}


def parse_update_cache(state_dir: Path, live_version: Optional[str]) -> Tuple[str, Optional[str]]:
    cache_file = state_dir / "last-update-check"
    if not cache_file.exists():
        return "upstream_unknown", None

    parts = cache_file.read_text().strip().split()
    if not parts:
        return "upstream_unknown", None
    if parts[0] == "UP_TO_DATE" and len(parts) >= 2 and parts[1] == live_version:
        return "upstream_current", parts[1]
    if parts[0] == "UPGRADE_AVAILABLE" and len(parts) >= 3 and parts[1] == live_version:
        return "upstream_stale", parts[2]
    return "upstream_unknown", None


def detect_upstream_status(item: dict, paths: dict, env) -> dict:
    version_path = expand_live_path(item.get("version_file", item["live_path"]), paths)
    live_version = version_path.read_text().strip() if version_path.exists() else None
    update_check_bin = expand_live_path(item.get("update_check_bin", ""), paths)

    result = {
        "id": item["id"],
        "label": item["label"],
        "live_version": live_version,
        "latest_version": None,
        "upstream_status": "upstream_unknown",
    }

    if not update_check_bin.exists():
        return result

    completed = run_command([str(update_check_bin)], env=env)
    first_line = next((line.strip() for line in completed.stdout.splitlines() if line.strip()), "")

    if first_line.startswith("UPGRADE_AVAILABLE "):
        _, old_version, remote_version = first_line.split(maxsplit=2)
        if old_version == live_version:
            result["upstream_status"] = "upstream_stale"
            result["latest_version"] = remote_version
            return result
    elif first_line.startswith("JUST_UPGRADED "):
        _, _old_version, new_version = first_line.split(maxsplit=2)
        result["upstream_status"] = "upstream_current"
        result["latest_version"] = new_version
        return result

    cache_status, latest_version = parse_update_cache(paths["gstack_state_dir"], live_version)
    result["upstream_status"] = cache_status
    result["latest_version"] = latest_version
    return result


def detect_stale(host: str, section: dict, env) -> list:
    """Detect files/folders not accounted for in the inventory."""
    root = repo_root()
    paths = home_paths()

    # Collect known repo paths from all inventory sections
    known_repo = set()
    for key in ("tracked_upstreams", "customized_by_me", "backup_only_personal_state"):
        for item in section[key]:
            known_repo.add(item["repo_path"])
    for asset in section.get("special_assets", []):
        known_repo.add(asset["repo_path"])

    def is_fully_covered(rel_path: str) -> bool:
        """Path is exactly known or is inside a known directory."""
        for k in known_repo:
            if rel_path == k or rel_path.startswith(k + "/"):
                return True
        return False

    def has_known_descendants(rel_path: str) -> bool:
        """Known paths exist under this directory."""
        for k in known_repo:
            if k.startswith(rel_path + "/"):
                return True
        return False

    stale = []

    # --- Repo-side: scan host mirror directory ---
    host_dir = root / host
    if host_dir.is_dir():
        for child in sorted(host_dir.iterdir()):
            if child.name.startswith("."):
                continue
            rel = str(child.relative_to(root))
            if is_fully_covered(rel):
                continue
            if not child.is_dir() or not has_known_descendants(rel):
                stale.append({
                    "path": rel,
                    "location": "repo",
                    "kind": "directory" if child.is_dir() else "file",
                })
            else:
                # Directory contains known paths but isn't itself known — scan one level deeper
                for grandchild in sorted(child.iterdir()):
                    if grandchild.name.startswith("."):
                        continue
                    grel = str(grandchild.relative_to(root))
                    if not is_fully_covered(grel) and not has_known_descendants(grel):
                        stale.append({
                            "path": grel,
                            "location": "repo",
                            "kind": "directory" if grandchild.is_dir() else "file",
                        })

    # --- Repo-side: scan project-local skill directory ---
    skill_prefix = ".claude/skills" if host == "claude" else ".agents/skills"
    skill_dir = root / skill_prefix
    if skill_dir.is_dir():
        for child in sorted(skill_dir.iterdir()):
            if child.name.startswith("."):
                continue
            rel = str(child.relative_to(root))
            if not is_fully_covered(rel) and not has_known_descendants(rel):
                stale.append({
                    "path": rel,
                    "location": "repo",
                    "kind": "directory" if child.is_dir() else "file",
                })

    # --- Live-side: scan live skills directory for untracked installs ---
    known_live_skill_names = set()
    for item in section["tracked_upstreams"]:
        parts = item["live_path"].split("/")
        if len(parts) >= 2 and parts[-2] == "skills":
            known_live_skill_names.add(parts[-1])

    live_home = paths["claude_home"] if host == "claude" else paths["codex_home"]
    live_skills_dir = live_home / "skills"
    if live_skills_dir.is_dir():
        for child in sorted(live_skills_dir.iterdir()):
            if child.name.startswith(".") or not child.is_dir():
                continue
            if child.name in known_live_skill_names:
                continue
            # Skip symlinks pointing into a tracked upstream (e.g., gstack-managed skills)
            if child.is_symlink():
                target = os.readlink(child)
                # Resolve absolute symlinks to check if they land inside a tracked upstream
                resolved = child.resolve()
                tracked_dirs = [live_skills_dir / name for name in known_live_skill_names]
                if any(
                    target.startswith(name + "/") or target.startswith("./" + name + "/")
                    or any(str(resolved).startswith(str(td) + "/") for td in tracked_dirs)
                    for name in known_live_skill_names
                ):
                    continue
            stale.append({
                "path": str(child),
                "location": "live",
                "kind": "directory",
            })

    return stale


def classify(section: dict, status_items: dict) -> dict:
    groups = {}
    for key in ("tracked_upstreams", "customized_by_me", "backup_only_personal_state"):
        groups[key] = []
        for item in section[key]:
            groups[key].append({**item, **status_items[item["id"]]})
    return groups


def reconcile(host: str, env) -> dict:
    section = load_inventory(host)
    current_status = status_by_id(host, env)
    grouped_before = classify(section, current_status)

    fixed_actions = []
    blocked_actions = []
    reported_only = []

    backup_candidates = []
    for key in ("tracked_upstreams", "backup_only_personal_state"):
        for item in grouped_before[key]:
            if item["status"] in {"needs_pull", "repo_missing"}:
                backup_candidates.append(item["id"])
            elif item["status"] in {"live_missing", "missing"}:
                reported_only.append(
                    {
                        "id": item["id"],
                        "reason": item["status"],
                        "recommended_action": item["recommended_action"],
                    }
                )

    if backup_candidates:
        run_sync("pull", host=host, scope="backup-only", env=env)
        fixed_actions.append({"command": "pull", "scope": "backup-only", "items": backup_candidates})

    repo_owned_candidates = []
    for item in grouped_before["customized_by_me"]:
        if item["status"] in {"needs_push", "live_missing"}:
            repo_owned_candidates.append(item["id"])
        elif item["status"] in {"repo_missing", "missing"}:
            reported_only.append(
                {
                    "id": item["id"],
                    "reason": item["status"],
                    "recommended_action": item["recommended_action"],
                }
            )

    safe_push = evaluate_safe_push_gate(host, section["customized_by_me"], env)
    if repo_owned_candidates:
        if safe_push["allowed"]:
            run_sync("push", host=host, scope="repo-owned", env=env)
            fixed_actions.append({"command": "push", "scope": "repo-owned", "items": repo_owned_candidates})
        else:
            blocked_actions.append(
                {
                    "command": "push",
                    "scope": "repo-owned",
                    "items": repo_owned_candidates,
                    "reasons": safe_push["reasons"],
                }
            )

    final_status = status_by_id(host, env)
    grouped_after = classify(section, final_status)
    paths = home_paths()
    tracked_upstreams = []
    for item in section["tracked_upstreams"]:
        snapshot = final_status[item["id"]]
        upstream = detect_upstream_status(item, paths, env)
        tracked_upstreams.append(
            {
                "id": item["id"],
                "label": item["label"],
                "snapshot_status": snapshot["status"],
                "repo_version": snapshot.get("repo_version"),
                "live_version": snapshot.get("live_version"),
                "upstream_status": upstream["upstream_status"],
                "latest_version": upstream["latest_version"],
            }
        )
        if upstream["upstream_status"] in {"upstream_stale", "upstream_unknown"}:
            reported_only.append(
                {
                    "id": item["id"],
                    "reason": upstream["upstream_status"],
                    "latest_version": upstream["latest_version"],
                }
            )

    stale_candidates = detect_stale(host, section, env)

    return {
        "host": host,
        "inventory_path": str(repo_root() / "home-inventory.json"),
        "safe_push": safe_push,
        "fixed_actions": fixed_actions,
        "blocked_actions": blocked_actions,
        "reported_only": reported_only,
        "status": grouped_after,
        "tracked_upstreams": tracked_upstreams,
        "special_assets": section.get("special_assets", []),
        "stale_candidates": stale_candidates,
    }


def print_text_report(result: dict) -> None:
    total_items = sum(len(items) for items in result["status"].values())
    special_assets = result.get("special_assets", [])
    stale_candidates = result.get("stale_candidates", [])

    def action_phrase(action: str) -> str:
        return {
            "pull": "pull live state back into the repo",
            "push": "push repo-owned state out to the live home",
            "none": "none",
        }.get(action, action)

    def print_item_block(item: dict) -> None:
        print(f"- {item['label']}")
        print(f"  checked: repo {item['repo_path']}")
        print(f"  against: live {item['live_path']}")
        print(f"  result: {item['status']}")
        if item.get("repo_version") or item.get("live_version"):
            print(
                "  versions: "
                f"repo={item.get('repo_version') or 'n/a'} "
                f"live={item.get('live_version') or 'n/a'}"
            )
        if item.get("backup_age_days") is not None:
            print(f"  backup age: {item['backup_age_days']} day(s)")
        print(f"  action: {action_phrase(item['recommended_action'])}")

    print(f"=== Home Health: {result['host']} ===")
    print("")
    print("Summary")
    print(f"- inventory: {result['inventory_path']}")
    print(f"- checked items: {total_items}")
    print(f"- special assets tracked: {len(special_assets)}")
    print(f"- fixed automatically: {len(result['fixed_actions'])}")
    print(f"- blocked actions: {len(result['blocked_actions'])}")
    print(f"- reported only: {len(result['reported_only'])}")
    print(f"- stale candidates: {len(stale_candidates)}")
    print("")
    print("Customized By Me")
    for item in result["status"]["customized_by_me"]:
        print_item_block(item)
    print("")
    print("Special Assets")
    if special_assets:
        for asset in special_assets:
            print(f"- {asset['label']} [{asset['category']}]")
            print(f"  repo path: {asset['repo_path']}")
            print(f"  why special: {asset['summary']}")
    else:
        print("- none tracked")
    print("")
    print("Tracked Upstreams")
    for item in result["tracked_upstreams"]:
        snapshot = next(entry for entry in result["status"]["tracked_upstreams"] if entry["id"] == item["id"])
        print(f"- {item['label']}")
        print(f"  checked snapshot: repo {snapshot['repo_path']}")
        print(f"  against live: {snapshot['live_path']}")
        print(f"  snapshot result: {item['snapshot_status']}")
        print(
            "  versions: "
            f"repo={item.get('repo_version') or 'n/a'} "
            f"live={item.get('live_version') or 'n/a'}"
        )
        print(f"  checked upstream: {snapshot.get('update_check_bin', 'n/a')}")
        print(f"  upstream result: {item['upstream_status']}")
        if item["latest_version"]:
            print(f"  latest seen: {item['latest_version']}")
        print(f"  action: {action_phrase(snapshot['recommended_action'])}")
    if result["status"]["backup_only_personal_state"]:
        print("")
        print("Backup-Only Personal State")
        for item in result["status"]["backup_only_personal_state"]:
            print_item_block(item)

    print("")
    print("Safe Push Gate")
    print(f"- allowed: {'yes' if result['safe_push']['allowed'] else 'no'}")
    for check in result["safe_push"].get("checks", []):
        state = "pass" if check["ok"] else "block"
        print(f"- {check['name']}: {state} ({check['detail']})")

    print("")
    print("Actions")
    if result["fixed_actions"]:
        for action in result["fixed_actions"]:
            items = ", ".join(action["items"])
            print(f"- fixed via {action['command']} {action['scope']}: {items}")
    else:
        print("- no automatic fixes were needed")

    for action in result["blocked_actions"]:
        items = ", ".join(action["items"])
        reasons = ", ".join(action["reasons"])
        print(f"- blocked {action['command']} {action['scope']} for {items}: {reasons}")

    if result["reported_only"]:
        print("")
        print("Reported Only")
        for item in result["reported_only"]:
            detail = item["reason"]
            if item.get("latest_version"):
                detail += f" (latest={item['latest_version']})"
            print(f"- {item['id']}: {detail}")
    else:
        print("")
        print("Reported Only")
        print("- none")

    print("")
    print("Stale Candidates")
    if stale_candidates:
        for entry in stale_candidates:
            print(f"- {entry['location']}: {entry['path']} ({entry['kind']})")
    else:
        print("- none")


def main() -> int:
    parser = argparse.ArgumentParser(description="Host-scoped retro reconcile helper for home-setup.")
    parser.add_argument("--host", required=True, choices=sorted(ALLOWED_HOSTS))
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args()

    env = os.environ.copy()
    env.setdefault("HOME_SETUP_REPO_ROOT", str(repo_root()))

    try:
        result = reconcile(args.host, env)
    except Exception as exc:
        if args.format == "json":
            json.dump({"host": args.host, "error": str(exc)}, sys.stdout, indent=2)
            sys.stdout.write("\n")
        else:
            print(f"home-health failed: {exc}", file=sys.stderr)
        return 1

    if args.format == "json":
        json.dump(result, sys.stdout, indent=2, sort_keys=True)
        sys.stdout.write("\n")
    else:
        print_text_report(result)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
