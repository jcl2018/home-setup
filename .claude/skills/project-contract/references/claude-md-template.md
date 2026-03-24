# CLAUDE.md Template

Use this as a starting point. Delete sections that don't apply. Keep it short.

```markdown
# CLAUDE.md — {repo-name}

{One-line description of what this repo is.}

## Commands

```bash
# Build
{exact build command}

# Test (full suite)
{exact test command}

# Test (single file)
{exact single-test command, if different}

# Lint
{exact lint command}
```

## Architecture

{2-5 bullet points describing the key module boundaries and data flow.
What talks to what. What's off-limits. Where the important code lives.}

## Conventions

{Only conventions that differ from language defaults or that Claude would
get wrong without being told. Skip obvious things.}

- {convention 1}
- {convention 2}

## Safety

{Things to never do. Destructive operations. Protected files. Production
guards. Skip if nothing unusual.}

- Never {dangerous thing}
- Always {safety practice}
```

## Guidelines for filling this in

- **Commands must actually run.** Don't guess — run them first.
- **Architecture should be scannable.** Bullet points, not paragraphs.
- **Conventions should surprise.** If it's standard for the language, skip it.
- **Safety should be specific.** "Be careful" is not a safety rail.
- **Total length: under 80 lines.** If longer, move detail to `.claude/rules/`.
