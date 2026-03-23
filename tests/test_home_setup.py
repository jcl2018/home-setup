import json
import os
import shutil
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path
from typing import Optional


REPO_ROOT = Path(__file__).resolve().parents[1]
SYNC_SCRIPT = REPO_ROOT / "sync.sh"
HOME_HEALTH = REPO_ROOT / "home_health.py"
FIXTURES = Path(__file__).resolve().parent / "fixtures"


def run(cmd, *, cwd=None, env=None, check=True):
    completed = subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        env=env,
        capture_output=True,
        text=True,
    )
    if check and completed.returncode != 0:
        raise AssertionError(
            f"command failed: {' '.join(cmd)}\nstdout:\n{completed.stdout}\nstderr:\n{completed.stderr}"
        )
    return completed


def write_file(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)


def write_json(path: Path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n")


def make_executable(path: Path):
    path.chmod(path.stat().st_mode | stat.S_IXUSR)


def sanitize_payload(payload, replacements):
    if isinstance(payload, dict):
        return {key: sanitize_payload(value, replacements) for key, value in payload.items()}
    if isinstance(payload, list):
        return [sanitize_payload(value, replacements) for value in payload]
    if isinstance(payload, str):
        sanitized = payload
        for old, new in replacements:
            sanitized = sanitized.replace(old, new)
        return sanitized
    return payload


def make_gstack_install(base_dir: Path, version: str, *, update_output: str = "", state_dir: Optional[Path] = None):
    write_file(base_dir / "VERSION", version + "\n")
    update_script = base_dir / "bin" / "gstack-update-check"
    write_file(
        update_script,
        "#!/usr/bin/env bash\n"
        "set -euo pipefail\n"
        "if [ -f \"${0}.output\" ]; then\n"
        "  cat \"${0}.output\"\n"
        "fi\n",
    )
    make_executable(update_script)
    if update_output:
        write_file(Path(str(update_script) + ".output"), update_output + "\n")
    if state_dir:
        state_dir.mkdir(parents=True, exist_ok=True)


def default_inventory():
    return json.loads((REPO_ROOT / "home-inventory.json").read_text())


class HomeSetupTestCase(unittest.TestCase):
    maxDiff = None

    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.temp_path = Path(self.tempdir.name)
        self.repo_root = self.temp_path / "repo"
        self.home_dir = self.temp_path / "home"
        self.claude_home = self.home_dir / ".claude"
        self.codex_home = self.home_dir / ".codex"
        self.codex_agents = self.home_dir / "AGENTS.md"
        self.gstack_state = self.home_dir / ".gstack"
        self.repo_root.mkdir(parents=True)
        self.claude_home.mkdir(parents=True)
        self.codex_home.mkdir(parents=True)
        self.gstack_state.mkdir(parents=True)
        self.env = os.environ.copy()
        self.env.update(
            {
                "HOME": str(self.home_dir),
                "HOME_SETUP_REPO_ROOT": str(self.repo_root),
                "HOME_SETUP_CLAUDE_HOME": str(self.claude_home),
                "HOME_SETUP_CODEX_HOME": str(self.codex_home),
                "HOME_SETUP_CODEX_AGENTS": str(self.codex_agents),
                "HOME_SETUP_GSTACK_STATE_DIR": str(self.gstack_state),
            }
        )
        write_json(self.repo_root / "home-inventory.json", default_inventory())

    def tearDown(self):
        self.tempdir.cleanup()

    def run_sync(self, *args):
        return run([str(SYNC_SCRIPT), *args], env=self.env, cwd=self.repo_root)

    def run_home_health(self, *args, env=None, check=True):
        merged_env = self.env.copy()
        if env:
            merged_env.update(env)
        return run(["python3", str(HOME_HEALTH), *args], env=merged_env, cwd=self.repo_root, check=check)

    def init_git_repo(self):
        run(["git", "init", "-b", "main"], cwd=self.repo_root, env=self.env)
        run(["git", "config", "user.name", "Test User"], cwd=self.repo_root, env=self.env)
        run(["git", "config", "user.email", "test@example.com"], cwd=self.repo_root, env=self.env)
        run(["git", "add", "."], cwd=self.repo_root, env=self.env)
        run(["git", "commit", "-m", "initial"], cwd=self.repo_root, env=self.env)
        bare_remote = self.temp_path / "origin.git"
        run(["git", "init", "--bare", str(bare_remote)], cwd=self.temp_path, env=self.env)
        run(["git", "remote", "add", "origin", str(bare_remote)], cwd=self.repo_root, env=self.env)
        run(["git", "push", "-u", "origin", "main"], cwd=self.repo_root, env=self.env)

    def prepare_codex_surface(self, *, repo_config="repo-config", live_config="repo-config", repo_agents="repo-agents", live_agents="repo-agents", repo_gstack="1.0.0", live_gstack="1.0.0", update_output=""):
        write_file(self.repo_root / "codex" / "config.toml", repo_config + "\n")
        write_file(self.repo_root / "codex" / "AGENTS.md", repo_agents + "\n")
        make_gstack_install(self.repo_root / "codex" / "skills" / "gstack", repo_gstack)
        write_file(self.codex_home / "config.toml", live_config + "\n")
        write_file(self.codex_agents, live_agents + "\n")
        make_gstack_install(self.codex_home / "skills" / "gstack", live_gstack, update_output=update_output, state_dir=self.gstack_state)

    def prepare_claude_surface(self, *, repo_settings=None, live_settings=None, repo_gstack="2.0.0", live_gstack="2.0.0", repo_templates=None, live_templates=None, repo_memory=None, live_memory=None, update_output=""):
        repo_settings = repo_settings or {"api_key": "abcd...<REDACTED>", "name": "repo"}
        live_settings = live_settings or {"api_key": "abcdefghijklmno", "name": "repo"}
        repo_templates = repo_templates or {"python-project.md": "repo template\n"}
        live_templates = live_templates or {}
        repo_memory = repo_memory or {}
        live_memory = live_memory or {}

        write_json(self.repo_root / "claude" / "settings.json", repo_settings)
        write_json(self.claude_home / "settings.json", live_settings)
        make_gstack_install(self.repo_root / "claude" / "skills" / "gstack", repo_gstack)
        make_gstack_install(self.claude_home / "skills" / "gstack", live_gstack, update_output=update_output, state_dir=self.gstack_state)

        for name, content in repo_templates.items():
            write_file(self.repo_root / "claude" / "templates" / name, content)
        for name, content in live_templates.items():
            write_file(self.claude_home / "templates" / name, content)

        for name, content in repo_memory.items():
            write_file(self.repo_root / "claude" / "projects" / name / "memory" / "notes.md", content)
        for name, content in live_memory.items():
            write_file(self.claude_home / "projects" / name / "memory" / "notes.md", content)

    def test_home_inventory_matches_golden_fixture(self):
        expected = json.loads((FIXTURES / "home-inventory.golden.json").read_text())
        actual = json.loads((REPO_ROOT / "home-inventory.json").read_text())
        self.assertEqual(actual, expected)

    def test_sync_status_codex_json_matches_golden_fixture(self):
        self.prepare_codex_surface(
            live_agents="live-agents",
            live_gstack="1.1.0",
        )

        payload = json.loads(self.run_sync("status", "--host", "codex", "--format", "json").stdout)
        sanitized = sanitize_payload(
            payload,
            [
                (str(self.repo_root), "<repo_root>"),
                (str(self.codex_home), "<codex_home>"),
                (str(self.home_dir), "<home>"),
            ],
        )
        expected = json.loads((FIXTURES / "status-codex.golden.json").read_text())
        self.assertEqual(sanitized, expected)

    def test_sync_status_claude_json_matches_golden_fixture(self):
        self.prepare_claude_surface(
            repo_templates={"python-project.md": "repo template\n"},
            live_templates={},
            live_memory={"demo-project": "new memory\n"},
        )

        payload = json.loads(self.run_sync("status", "--host", "claude", "--format", "json").stdout)
        sanitized = sanitize_payload(
            payload,
            [
                (str(self.repo_root), "<repo_root>"),
                (str(self.claude_home), "<claude_home>"),
                (str(self.home_dir), "<home>"),
            ],
        )
        expected = json.loads((FIXTURES / "status-claude.golden.json").read_text())
        self.assertEqual(sanitized, expected)

    def test_sync_pull_backup_only_codex_does_not_import_repo_owned_files(self):
        self.prepare_codex_surface(
            repo_config="repo-config",
            live_config="live-config",
            repo_gstack="1.0.0",
            live_gstack="1.1.0",
        )

        self.run_sync("pull", "--host", "codex", "--scope", "backup-only")

        self.assertEqual((self.repo_root / "codex" / "config.toml").read_text(), "repo-config\n")
        self.assertEqual((self.repo_root / "codex" / "skills" / "gstack" / "VERSION").read_text(), "1.1.0\n")

    def test_sync_push_repo_owned_codex_does_not_touch_gstack(self):
        self.prepare_codex_surface(
            repo_config="repo-config",
            live_config="live-config",
            repo_agents="repo-agents",
            live_agents="live-agents",
            repo_gstack="1.0.0",
            live_gstack="1.1.0",
        )

        self.run_sync("push", "--host", "codex", "--scope", "repo-owned")

        self.assertEqual((self.codex_home / "config.toml").read_text(), "repo-config\n")
        self.assertEqual(self.codex_agents.read_text(), "repo-agents\n")
        self.assertEqual((self.codex_home / "skills" / "gstack" / "VERSION").read_text(), "1.1.0\n")

    def test_home_health_codex_reconciles_safe_drift(self):
        self.prepare_codex_surface(
            repo_config="repo-config",
            live_config="live-config",
            repo_agents="repo-agents",
            live_agents="live-agents",
            repo_gstack="1.0.0",
            live_gstack="1.1.0",
            update_output="UPGRADE_AVAILABLE 1.1.0 1.2.0",
        )
        self.init_git_repo()

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertTrue(payload["safe_push"]["allowed"])
        self.assertEqual(payload["fixed_actions"], [
            {"command": "pull", "scope": "backup-only", "items": ["gstack"]},
            {"command": "push", "scope": "repo-owned", "items": ["config.toml", "AGENTS.md"]},
        ])
        self.assertEqual((self.repo_root / "codex" / "skills" / "gstack" / "VERSION").read_text(), "1.1.0\n")
        self.assertEqual((self.codex_home / "config.toml").read_text(), "repo-config\n")
        self.assertEqual(self.codex_agents.read_text(), "repo-agents\n")
        self.assertEqual(payload["tracked_upstreams"][0]["upstream_status"], "upstream_stale")

    def test_home_health_codex_ignores_claude_drift(self):
        self.prepare_codex_surface(repo_gstack="1.0.0", live_gstack="1.1.0")
        self.prepare_claude_surface(repo_gstack="2.0.0", live_gstack="2.1.0")
        self.init_git_repo()

        before_claude = (self.repo_root / "claude" / "skills" / "gstack" / "VERSION").read_text()
        self.run_home_health("--host", "codex", "--format", "json")
        after_claude = (self.repo_root / "claude" / "skills" / "gstack" / "VERSION").read_text()

        self.assertEqual(before_claude, after_claude)
        self.assertEqual((self.repo_root / "codex" / "skills" / "gstack" / "VERSION").read_text(), "1.1.0\n")

    def test_home_health_blocks_repo_owned_push_for_each_gate_reason(self):
        scenarios = {
            "wrong_branch": self._scenario_wrong_branch,
            "dirty_worktree": self._scenario_dirty_worktree,
            "baseline_drift": self._scenario_baseline_drift,
            "unexpected_missing_live:config.toml": self._scenario_missing_live_target,
            "host_mismatch": self._scenario_host_mismatch,
        }
        for expected_reason, setup in scenarios.items():
            with self.subTest(reason=expected_reason):
                self.tearDown()
                self.setUp()
                self.prepare_codex_surface(
                    repo_config="repo-config",
                    live_config="live-config",
                    repo_agents="repo-agents",
                    live_agents="live-agents",
                    repo_gstack="1.0.0",
                    live_gstack="1.1.0",
                )
                self.init_git_repo()
                extra_env = setup()

                payload = json.loads(self.run_home_health("--host", "codex", "--format", "json", env=extra_env).stdout)

                self.assertIn(expected_reason, payload["blocked_actions"][0]["reasons"])
                if expected_reason == "unexpected_missing_live:config.toml":
                    self.assertFalse((self.codex_home / "config.toml").exists())
                else:
                    self.assertEqual((self.codex_home / "config.toml").read_text(), "live-config\n")
                self.assertEqual((self.repo_root / "codex" / "skills" / "gstack" / "VERSION").read_text(), "1.1.0\n")

    def _scenario_wrong_branch(self):
        run(["git", "checkout", "-b", "codex/test"], cwd=self.repo_root, env=self.env)
        return {}

    def _scenario_dirty_worktree(self):
        write_file(self.repo_root / "codex" / "config.toml", "dirty-config\n")
        return {}

    def _scenario_baseline_drift(self):
        write_file(self.repo_root / "codex" / "config.toml", "new-repo-config\n")
        run(["git", "add", "codex/config.toml"], cwd=self.repo_root, env=self.env)
        run(["git", "commit", "-m", "local drift"], cwd=self.repo_root, env=self.env)
        return {}

    def _scenario_missing_live_target(self):
        inventory = default_inventory()
        inventory["codex"]["customized_by_me"][0]["allow_create"] = False
        write_json(self.repo_root / "home-inventory.json", inventory)
        (self.codex_home / "config.toml").unlink()
        return {}

    def _scenario_host_mismatch(self):
        return {"HOME_SETUP_RUNTIME_HOST": "claude"}

    def test_home_health_fails_loudly_for_malformed_inventory(self):
        write_json(self.repo_root / "home-inventory.json", {"codex": {"tracked_upstreams": []}})
        completed = self.run_home_health("--host", "codex", "--format", "json", check=False)

        self.assertNotEqual(completed.returncode, 0)
        payload = json.loads(completed.stdout)
        self.assertIn("error", payload)

    def test_home_health_text_report_lists_each_check_in_detail(self):
        self.prepare_codex_surface(
            repo_config="repo-config",
            live_config="live-config",
            repo_agents="repo-agents",
            live_agents="live-agents",
            repo_gstack="1.0.0",
            live_gstack="1.1.0",
            update_output="UPGRADE_AVAILABLE 1.1.0 1.2.0",
        )
        self.init_git_repo()

        output = self.run_home_health("--host", "codex").stdout

        self.assertIn("Summary", output)
        self.assertIn("Customized By Me", output)
        self.assertIn("Special Assets", output)
        self.assertIn("Tracked Upstreams", output)
        self.assertIn("special assets tracked:", output)
        self.assertIn("Safe Push Gate", output)
        self.assertIn("checked: repo", output)
        self.assertIn("against: live", output)
        self.assertIn("snapshot result:", output)
        self.assertIn("upstream result:", output)
        self.assertIn("action:", output)
        self.assertIn("repo-local home-retro wrapper [skill]", output)
        self.assertIn("why special:", output)


    def test_home_health_detects_stale_repo_files(self):
        self.prepare_claude_surface()
        self.init_git_repo()

        # Add an untracked directory inside claude/skills/
        write_file(self.repo_root / "claude" / "skills" / "custom" / "SKILL.md", "stale skill\n")
        # Add an untracked file at claude/ top level
        write_file(self.repo_root / "claude" / "old-notes.txt", "leftover\n")
        # Add an untracked project-local skill
        write_file(self.repo_root / ".claude" / "skills" / "audit" / "SKILL.md", "old audit\n")

        payload = json.loads(self.run_home_health("--host", "claude", "--format", "json").stdout)

        stale_paths = [e["path"] for e in payload["stale_candidates"]]
        self.assertIn("claude/old-notes.txt", stale_paths)
        self.assertIn("claude/skills/custom", stale_paths)
        self.assertIn(".claude/skills/audit", stale_paths)
        # Known paths must NOT appear
        for p in stale_paths:
            self.assertNotIn("gstack", p)
            self.assertNotIn("home-retro", p)

    def test_home_health_detects_stale_live_skills(self):
        self.prepare_codex_surface()
        self.init_git_repo()

        # Add an unexpected skill in the live codex skills dir
        write_file(self.codex_home / "skills" / "old-plugin" / "SKILL.md", "leftover\n")

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        stale_paths = [e["path"] for e in payload["stale_candidates"]]
        live_stale = [e for e in payload["stale_candidates"] if e["location"] == "live"]
        self.assertEqual(len(live_stale), 1)
        self.assertIn("old-plugin", live_stale[0]["path"])

    def test_home_health_no_stale_when_clean(self):
        self.prepare_claude_surface()
        self.init_git_repo()

        # Add the expected project-local skill
        write_file(self.repo_root / ".claude" / "skills" / "home-retro" / "SKILL.md", "retro\n")

        payload = json.loads(self.run_home_health("--host", "claude", "--format", "json").stdout)

        self.assertEqual(payload["stale_candidates"], [])

    def test_home_health_text_report_includes_stale_section(self):
        self.prepare_codex_surface()
        self.init_git_repo()

        write_file(self.codex_home / "skills" / "leftover" / "SKILL.md", "stale\n")

        output = self.run_home_health("--host", "codex").stdout

        self.assertIn("Stale Candidates", output)
        self.assertIn("leftover", output)


    # --- Docs Health tests ---

    def test_docs_health_philosophy_present(self):
        self.prepare_codex_surface()
        self.init_git_repo()
        write_file(self.repo_root / "PHILOSOPHY.md", "This is the philosophy.\n")
        (self.repo_root / "profiles").mkdir(parents=True, exist_ok=True)
        write_file(self.repo_root / "profiles" / "setup-guide.md", "guide\n")

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertTrue(payload["docs_health"]["philosophy_exists"])

    def test_docs_health_philosophy_missing(self):
        self.prepare_codex_surface()
        self.init_git_repo()

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertFalse(payload["docs_health"]["philosophy_exists"])

    def test_docs_health_philosophy_empty(self):
        self.prepare_codex_surface()
        self.init_git_repo()
        write_file(self.repo_root / "PHILOSOPHY.md", "")

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertFalse(payload["docs_health"]["philosophy_exists"])

    def test_docs_health_profiles_present(self):
        self.prepare_codex_surface()
        self.init_git_repo()
        write_file(self.repo_root / "profiles" / "personal-mac.md", "profile\n")
        write_file(self.repo_root / "profiles" / "work-windows.md", "profile\n")

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertTrue(payload["docs_health"]["profiles_dir_exists"])
        self.assertEqual(payload["docs_health"]["profile_count"], 2)

    def test_docs_health_profiles_missing(self):
        self.prepare_codex_surface()
        self.init_git_repo()

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertFalse(payload["docs_health"]["profiles_dir_exists"])
        self.assertEqual(payload["docs_health"]["profile_count"], 0)

    def test_docs_health_profiles_empty(self):
        self.prepare_codex_surface()
        self.init_git_repo()
        (self.repo_root / "profiles").mkdir(parents=True, exist_ok=True)

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertTrue(payload["docs_health"]["profiles_dir_exists"])
        self.assertEqual(payload["docs_health"]["profile_count"], 0)

    def test_docs_health_profile_match_via_os(self):
        self.prepare_codex_surface()
        self.init_git_repo()

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        # Running on macOS, so platform.system() returns "Darwin"
        # The default inventory has profiles.Darwin = "personal-mac"
        self.assertEqual(payload["docs_health"]["current_profile"], "personal-mac")
        self.assertIn("os:", payload["docs_health"]["profile_source"])

    def test_docs_health_profile_override_via_env(self):
        self.prepare_codex_surface()
        self.init_git_repo()

        payload = json.loads(self.run_home_health(
            "--host", "codex", "--format", "json",
            env={"HOME_PROFILE": "work-windows"},
        ).stdout)

        self.assertEqual(payload["docs_health"]["current_profile"], "work-windows")
        self.assertEqual(payload["docs_health"]["profile_source"], "HOME_PROFILE")

    def test_docs_health_no_profile_match_fallback(self):
        self.prepare_codex_surface()
        self.init_git_repo()
        # Remove the "profiles" key from inventory
        inventory = default_inventory()
        inventory.pop("profiles", None)
        write_json(self.repo_root / "home-inventory.json", inventory)

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertEqual(payload["docs_health"]["current_profile"], "unknown profile")
        self.assertEqual(payload["docs_health"]["profile_source"], "no match")

    def test_docs_health_setup_guide_present(self):
        self.prepare_codex_surface()
        self.init_git_repo()
        write_file(self.repo_root / "profiles" / "setup-guide.md", "guide\n")

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertTrue(payload["docs_health"]["setup_guide_exists"])

    def test_docs_health_setup_guide_missing(self):
        self.prepare_codex_surface()
        self.init_git_repo()

        payload = json.loads(self.run_home_health("--host", "codex", "--format", "json").stdout)

        self.assertFalse(payload["docs_health"]["setup_guide_exists"])

    def test_docs_health_in_text_report(self):
        self.prepare_codex_surface()
        self.init_git_repo()
        write_file(self.repo_root / "PHILOSOPHY.md", "Philosophy content.\n")
        write_file(self.repo_root / "profiles" / "personal-mac.md", "profile\n")
        write_file(self.repo_root / "profiles" / "setup-guide.md", "guide\n")

        output = self.run_home_health("--host", "codex").stdout

        self.assertIn("Docs Health", output)
        self.assertIn("PHILOSOPHY.md: present", output)
        self.assertIn("profiles/:", output)
        self.assertIn("setup-guide.md: present", output)
        self.assertIn("current profile:", output)


if __name__ == "__main__":
    unittest.main()
