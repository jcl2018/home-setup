# Last updated

- 2026-03-16

## Goal

- Keep the local `home-setup` mirror checkout out of the normal project workspace by relocating it away from `C:\Users\chang\Documents\projects`.

## Current state

- Updated the weekly home-health automation so its skill link, audited paths, and `cwds` target `C:/Users/chang`.
- Replaced the repo-bootstrap skill's hardcoded sibling-skill links with relative links that work on this machine.
- Converted `C:\Users\chang\.codex\home_setup_summary.md` into a retired redirect note so it no longer reads like an active contract source.
- Copied the `home-setup` mirror checkout to `C:\Users\chang\.codex-mirrors\home-setup`, verified the git remote and worktree state there, and then removed the old checkout from the normal project workspace root.
- The mirror repo now lives under a hidden root that is outside the normal project workspace, so it should stop polluting repo context under `Documents\projects`.
- The remaining optional follow-up is publishing the refreshed mirror checkout if you want the canonical remote to match the fixed live files.

## Decisions / constraints

- Do not commit or push the mirror repo unless the user explicitly asks.
- Keep `C:\Users\chang\.codex\config.toml` managed as-is, including the Windows sandbox block, so local exports preserve the real live setup.
- Retire the legacy summary file in place rather than deleting it.
- Keep the local mirror under `C:\Users\chang\.codex-mirrors\home-setup` instead of `C:\Users\chang\Documents\projects`.

## Files touched

- `C:\Users\chang\.codex\.local-work\current.md`
- `C:\Users\chang\.codex\automations\weekly-codex-health\automation.toml`
- `C:\Users\chang\.codex\skills\lv1-workflow-repo-bootstrap\SKILL.md`
- `C:\Users\chang\.codex\skills\lv1-workflow-repo-bootstrap\references\existing-repo.md`
- `C:\Users\chang\.codex\home_setup_summary.md`
- `C:\Users\chang\.codex-mirrors\home-setup`

## Verification

- `Get-Content -Raw C:\Users\chang\.codex\automations\weekly-codex-health\automation.toml` -> pass
- `Get-Content -Raw C:\Users\chang\.codex\skills\lv1-workflow-repo-bootstrap\SKILL.md` -> pass
- `Get-Content -Raw C:\Users\chang\.codex\skills\lv1-workflow-repo-bootstrap\references\existing-repo.md` -> pass
- `Get-Content -Raw C:\Users\chang\.codex\home_setup_summary.md` -> pass
- `$legacy = '/' + 'Users/chjiang'; $repo = 'C:\Users\chang\AppData\Local\Temp\home-setup-audit-fa9c525d-8944-4c98-ab96-9b3c49dee298'; $manifest = Get-Content -Raw (Join-Path $repo 'codex-home-manifest.toml'); $matches = [regex]::Matches($manifest, 'path = "([^"]+)"\r?\nkind = "text"', 'Multiline'); $paths = $matches | ForEach-Object { Join-Path 'C:\Users\chang' (($_.Groups[1].Value).Replace('/', '\')) }; Select-String -Path $paths -Pattern $legacy` -> pass (no results after the handoff refresh)
- `C:\Users\chang\AppData\Local\Programs\Python\Python312\python.exe C:\Users\chang\.codex\skills\lv0-home-codex-settings-export\scripts\export_codex_home.py --repo C:\Users\chang\.codex-mirrors\home-setup` -> pass
- `$old = Join-Path $env:USERPROFILE 'Documents\\projects\\home-setup'; Test-Path $old; Test-Path C:\Users\chang\.codex-mirrors\home-setup` -> pass (`False`, `True`)
- `git -C C:\Users\chang\.codex-mirrors\home-setup remote -v` -> pass
- `git -C C:\Users\chang\.codex-mirrors\home-setup diff --name-status` -> pass (mirror checkout retains the expected unpublished snapshot changes after relocation)
- `$legacy = '/' + 'Users/chjiang'; Select-String -Path (Get-ChildItem C:\Users\chang\.codex-mirrors\home-setup -Recurse -File | Where-Object { $_.FullName -notmatch '\\.git\\' } | Select-Object -ExpandProperty FullName) -Pattern $legacy` -> pass (no results in the relocated local mirror checkout)
- `cmd /c rd /s /q <old project-root mirror path>` -> pass

## Next steps

- Commit and push `C:\Users\chang\.codex-mirrors\home-setup` only if you want the canonical mirror remote updated to match the fixed live home setup.

## Blockers / risks

- The canonical mirror remote still lags until the local mirror checkout is committed and pushed.
- `git status` in `C:\Users\chang\.codex-mirrors\home-setup` is noisy in this Windows environment because line-ending normalization marks many files as modified.

## Rollback notes

- Revert the edited live files above if you want to restore the previous local behavior.
- Move the mirror repo back into `C:\Users\chang\Documents\projects` only if you intentionally want it in the normal workspace again.
- Discard the unpublished worktree changes in `C:\Users\chang\.codex-mirrors\home-setup` only if you intentionally want the local mirror checkout to stop matching the current live home setup.
