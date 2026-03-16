# Duplicate To A Windows Machine

Use this flow when you want a second Windows machine to pick up the same portable shared Codex layer without copying Unix shell setup, secrets, or Codex runtime state.

## What Gets Copied

- `%USERPROFILE%\AGENTS.md`
- `%USERPROFILE%\.codex\config.toml`
- `%USERPROFILE%\.codex\home_setup_summary.md`
- `%USERPROFILE%\.codex\knowledge\**`
- `%USERPROFILE%\.codex\skills\**`
- optional `%USERPROFILE%\.codex\automations\weekly-codex-health\automation.toml`

The PowerShell installer renders `__HOME__` placeholders to a slash-normalized absolute path such as `C:/Users/name` so Markdown links inside the shared files still work.

## What Does Not Get Copied

- `.gitconfig`
- `.zprofile`
- Homebrew or Brewfile setup
- `~/.config/home-setup/secrets.zsh`
- `.codex/auth.json`
- `.codex/logs_*.sqlite*`, `.codex/state_*.sqlite*`
- `.codex/models_cache.json`, `.codex/sessions`, `.codex/shell_snapshots`
- bundled `.codex/skills/.system/*` skills that ship with the Codex runtime

## Recommended Flow

Clone this repo on the Windows machine, then run:

```powershell
pwsh -NoLogo -NoProfile -File .\scripts\audit-home.ps1
pwsh -NoLogo -NoProfile -File .\scripts\install.ps1
pwsh -NoLogo -NoProfile -File .\scripts\audit-home.ps1
```

If you also want the weekly Codex health automation:

```powershell
pwsh -NoLogo -NoProfile -File .\scripts\install.ps1 -WithAutomation
```

## Optional Target Path

If you want to render into a different home-like folder first:

```powershell
pwsh -NoLogo -NoProfile -File .\scripts\install.ps1 -TargetHome C:\temp\home-clone
```

The audit script supports the same `-TargetHome` flag.

## Post-Install Local Steps

- Install and sign in to Codex on the Windows machine so `.codex/auth.json` and bundled `.system` skills appear locally.
- Set any machine-local environment variables or secrets through your preferred Windows mechanism. Keep them out of this repo.
- Configure Git identity and any Windows-specific shell/profile setup locally instead of trying to force Unix parity from this repo.
- Decide whether the optional automation should stay enabled on that machine.
