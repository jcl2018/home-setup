# Bootstrap Checklist

Quick reference for what a well-bootstrapped repo looks like.

## Minimum Viable Setup

- [ ] `CLAUDE.md` exists with real commands that actually run
- [ ] At least one verification command has been run successfully
- [ ] Stack is identified (languages, frameworks, package manager)

## Good Setup

Everything in minimum, plus:

- [ ] `CLAUDE.md` has architecture section (module boundaries, data flow)
- [ ] `CLAUDE.md` has conventions section (only non-obvious ones)
- [ ] Test command runs and the result is known (pass, fail, or "no tests")
- [ ] Domain knowledge checked (`~/.claude/knowledge/` scanned for relevance)

## Great Setup

Everything in good, plus:

- [ ] `.claude/rules/` has path-specific rules for complex modules
- [ ] Safety rails documented (what to never do in this repo)
- [ ] Single-test command documented (not just full suite)
- [ ] CI configuration identified and referenced
