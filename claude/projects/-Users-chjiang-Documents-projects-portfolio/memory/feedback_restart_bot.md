---
name: restart-discord-bot-after-changes
description: After any code change to the Discord bot or its dependencies, restart the bot via launchctl so the user sees the change immediately
type: feedback
---

After any code change that affects the Discord bot (embeds, handlers, views, dashboard, etc.), restart the bot process so the user sees the change in Discord immediately.

**Why:** The bot runs as a long-lived launchd service with KeepAlive. Code changes aren't picked up until restart. The user asked to have this done automatically after changes.

**How to apply:** Run `launchctl kickstart -k gui/$(id -u)/com.portfolio.discord-bot` after editing any file the bot depends on. Verify with `tail -3 data/discord-bot.log` to confirm it came back online.
