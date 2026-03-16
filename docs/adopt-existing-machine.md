# Adopt On An Existing Machine

Use this flow when the target machine already has a meaningful home folder and you want to move it toward this reference setup without overwriting everything.

## Start With A Read-Only Audit

From this repo, run:

```sh
./scripts/audit-home.sh
```

This shows which reference pieces are already present, which are missing, and which items are intentionally local-only.

## Compare And Merge By Area

### `~/AGENTS.md`

- Compare the existing home contract with `templates/AGENTS.md`.
- Keep the reference design principles:
  small global rules, explicit verification, safety rails, and skill-routing.
- Merge only the parts that make sense for that machine.

### Shell Init

- Inspect the current shell startup files.
- The reference model expects `~/.zprofile` to do two things:
  initialize Homebrew and source `~/.config/home-setup/secrets.zsh` if present.
- If the target machine already has richer shell setup, add the hook without discarding unrelated local logic.

### Git Config

- Compare the current `~/.gitconfig` with `templates/.gitconfig`.
- Keep the shared defaults that matter to your workflow.
- Preserve machine- or identity-specific settings locally.

### `~/.codex` Layout

- Compare `~/.codex/config.toml`, the custom skills, and the knowledge notes with the reference catalog.
- Add missing shared skills or notes selectively.
- Do not copy over auth, logs, caches, sessions, or shell snapshots.

### Local Secrets

- Create `~/.config/home-setup/secrets.zsh` if the machine needs local API keys or env vars.
- Keep that file local-only and out of Git.

### Automation

- Decide whether the `weekly-codex-health` automation is useful on that machine.
- If yes, render or recreate it.
- If not, skip it without treating the machine as misconfigured.

## Recommended Adoption Order

1. `~/AGENTS.md`
2. shell init hook
3. `~/.codex/config.toml`
4. custom shared skills
5. knowledge notes
6. optional automation
7. local secrets file

## Optional Bootstrap Shortcut

If the target machine is clean enough that you want a quicker starting point, you can still use:

```sh
./scripts/install.sh --brew
```

Treat that as a convenience bootstrap. For an already-lived-in machine, the compare-and-merge path should stay the default.
