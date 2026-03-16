# Last updated

- 2026-03-16

## Goal

- Align the live Codex home control layer with the canonical `jcl2018/home-setup` remote and leave the local mirror checkout usable as the cache for future audits.

## Current state

- Audited the live home setup against the canonical remote and confirmed the drift was limited to the tracking doc, weekly home-health automation, Windows sandbox config, and two repo-bootstrap workflow files.
- Fast-forwarded `C:\Users\chang\.codex-mirrors\home-setup` to `origin/main`, then re-exported the live home control layer into that checkout with the export script.
- Pushed `Refresh Codex home mirror` to `origin/main`, so the canonical remote now matches the live home files that had drifted.
- Set `user.name` and `user.email` only in the local mirror checkout so the sync could reuse the repo's existing commit identity without changing global Git config.
- Refreshed this handoff, re-exported it into the mirror, and pushed the closing handoff update so the local home state and canonical remote end the session aligned.

## Decisions / constraints

- Keep the local mirror at `C:\Users\chang\.codex-mirrors\home-setup`, outside the normal project workspace.
- Use `lv0-home-codex-settings-export` as the source of truth for mirror refreshes instead of manually copying managed files.
- Leave unrelated local mirror noise such as the untracked `.local-work/` directory untouched because it is outside the managed export roots.
- Keep the autostash entry created during the pull in place unless the user explicitly asks to drop it.
- Keep the Git author identity override local to `C:\Users\chang\.codex-mirrors\home-setup`.

## Files touched

- `C:\Users\chang\.codex\.local-work\current.md`
- `C:\Users\chang\.codex\automations\weekly-codex-health\automation.toml`
- `C:\Users\chang\.codex\config.toml`
- `C:\Users\chang\.codex\skills\lv1-workflow-repo-bootstrap\SKILL.md`
- `C:\Users\chang\.codex\skills\lv1-workflow-repo-bootstrap\references\existing-repo.md`
- `C:\Users\chang\.codex-mirrors\home-setup`

## Verification

- `git -C C:\Users\chang\.codex-mirrors\home-setup fetch origin` -> pass
- `git -C C:\Users\chang\.codex-mirrors\home-setup pull --rebase --autostash origin main` -> pass after temporarily moving the conflicting local `umbrella-repo.md`; the pre-pull snapshot remains available as `stash@{0}`
- `C:\Users\chang\AppData\Local\Programs\Python\Python312\python.exe C:\Users\chang\.codex\skills\lv0-home-codex-settings-export\scripts\export_codex_home.py --repo C:\Users\chang\.codex-mirrors\home-setup` -> pass
- `git -C C:\Users\chang\.codex-mirrors\home-setup diff --cached --stat` -> pass
- `git -C C:\Users\chang\.codex-mirrors\home-setup commit -m "Refresh Codex home mirror"` -> pass
- `git -C C:\Users\chang\.codex-mirrors\home-setup push origin main` -> pass
- `C:\Users\chang\AppData\Local\Programs\Python\Python312\python.exe C:\Users\chang\.codex\skills\lv0-home-codex-settings-export\scripts\export_codex_home.py --repo C:\Users\chang\.codex-mirrors\home-setup` -> pass (handoff refresh)
- `git -C C:\Users\chang\.codex-mirrors\home-setup commit -m "Refresh home export handoff"` -> pass
- `git -C C:\Users\chang\.codex-mirrors\home-setup push origin main` -> pass
- `git -C C:\Users\chang\.codex-mirrors\home-setup rev-parse HEAD` and `git ls-remote https://github.com/jcl2018/home-setup.git HEAD` -> pass (local and remote `HEAD` match after the closing push)

## Next steps

- None for the remote-alignment work.
- Optional: drop `stash@{0}` and remove the untracked mirror-local `.local-work/` directory if you want a perfectly clean cache checkout.

## Blockers / risks

- No blocker remains for the remote alignment itself.
- The local mirror checkout still contains an untracked `.local-work/` directory and an autostash entry, which are harmless but keep the checkout from feeling fully pristine.
- Future live home edits will need another export before the remote mirror matches again.

## Rollback notes

- Revert `01e5971` in `C:\Users\chang\.codex-mirrors\home-setup` and push the revert if you want to undo the synced mirror snapshot.
- Remove the repo-local Git identity from `C:\Users\chang\.codex-mirrors\home-setup\.git\config` if you want that checkout to stop carrying its own author settings.
- Re-run the export workflow after any rollback so `codex-home-manifest.toml` stays in sync with the mirrored file set.
