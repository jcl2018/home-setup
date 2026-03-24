---
name: domain-context
description: |
  Load or capture domain knowledge for the current task. Reads from
  ~/.claude/knowledge/ to find relevant architecture notes, glossaries,
  and deep dives. Two modes: read (consult existing knowledge) and
  capture (write new knowledge after a deep dive).
  Use when asked to "load context", "what do we know about X",
  "save this knowledge", "domain context", or "capture what we learned".
---

# Domain Context

Load relevant domain knowledge into the current session, or capture new
knowledge after a deep dive. This skill bridges the gap between Claude Code's
atomic memory system and the need for structured, persistent domain knowledge.

## When to Use

**Read mode (default):**
- Starting work in a repo with known domain complexity
- User asks "what do we know about X?"
- A task clearly points to a known domain (AEDT, a specific architecture, etc.)
- Called by `/repo-bootstrap` to check for available context

**Capture mode:**
- After a deep dive that uncovered reusable knowledge
- User says "save this", "remember this architecture", "capture what we learned"
- When the same concepts keep being rediscovered across sessions

## Knowledge Directory

Shared knowledge files are maintained in the home-setup repo under `knowledge/` and
deployed to `~/.claude/knowledge/`. Machine-local domains (like `aedt/`) are declared
in the machine's profile under "Expected Local Content" and exist only in the installed
`~/.claude/knowledge/`. Use `/sync-audit` to verify shared files are in sync.

All domain knowledge lives under `~/.claude/knowledge/`:

```
~/.claude/knowledge/
├── INDEX.md                    ← what domains exist, routing hints
├── glossary.md                 ← shared terminology across domains
├── system-map.md               ← architecture relationships
├── common-gotchas.md           ← cross-domain sharp edges
├── aedt/
│   ├── INDEX.md                ← domain overview + what's here
│   ├── modules/                ← per-module deep dives
│   │   ├── solver.md
│   │   └── mesher.md
│   └── flows/                  ← cross-module flow descriptions
│       └── simulation-pipeline.md
└── <other-domain>/
    ├── INDEX.md
    └── ...
```

**This is NOT CC's memory system.** Memory stores small atomic facts (user prefs,
project decisions). Knowledge stores structural understanding (how a solver
pipeline works, what modules interact, domain terminology). Different shape,
different location, different purpose.

## Read Mode

### Step 1: Check if knowledge exists

```bash
ls ~/.claude/knowledge/INDEX.md 2>/dev/null && echo "KNOWLEDGE_EXISTS" || echo "NO_KNOWLEDGE"
```

If `NO_KNOWLEDGE`: tell the user "No domain knowledge found. Use `/domain-context capture`
after a deep dive to start building it." Then stop.

### Step 2: Route to the right domain

1. Read `~/.claude/knowledge/INDEX.md`
2. Identify which domain is relevant from:
   - The current repo path or project name
   - The task description or user's question
   - Explicit user cue ("load AEDT context")
3. If no domain matches, say so and stop — don't force-load unrelated knowledge

### Step 3: Load the smallest slice

1. Read the matching domain `INDEX.md`
2. Load at most: domain INDEX + 1-2 relevant deep dives
3. Do NOT load the entire domain tree — context is expensive

### Step 4: Present and proceed

Output what was loaded: "Loaded {domain} context: {what's covered}. Key points: ..."

Then continue with the user's actual task, using the loaded knowledge as background.

### Important: Knowledge is cache, not truth

- If repo code disagrees with a knowledge note, **the repo wins**
- Knowledge notes have a `last checked` date — flag if stale
- Never cite knowledge as authoritative — always verify against current code

## Capture Mode

Triggered when user explicitly asks to save knowledge, or says "capture this."

### Step 1: Confirm scope

Ask via AskUserQuestion:

> What scope is this knowledge?
> A) Global — useful across multiple repos (goes in `~/.claude/knowledge/`)
> B) Domain-specific — belongs under an existing domain (e.g., `aedt/`)
> C) New domain — needs a new domain directory

### Step 2: Choose the target

- **Global:** pick the smallest fitting file (`glossary.md`, `system-map.md`,
  `common-gotchas.md`, or a new top-level note)
- **Existing domain:** pick `modules/`, `flows/`, or a new deep-dive note
- **New domain:** create `~/.claude/knowledge/<domain>/INDEX.md` first

### Step 3: Write the note

Each note must include:

```markdown
# {Title}

**Scope:** {what this covers}
**When to use:** {what tasks benefit from this knowledge}
**Last checked:** {YYYY-MM-DD}

## Summary

{Concise summary of the knowledge — architecture, relationships, patterns,
 gotchas. Prefer structure over prose.}

## Key Files / Sources

- {file or doc this was derived from}
- {file or doc this was derived from}
```

### Step 4: Update INDEX.md

Add or update the entry in the relevant `INDEX.md` so future routing can find it.

### Step 5: Confirm

Tell the user what was saved and where: "Saved {title} to `~/.claude/knowledge/{path}`.
It will be available via `/domain-context` in future sessions."

## Rules

- **Smallest slice principle.** Never load more knowledge than the task needs.
  Start with INDEX, add deep dives only when the task proves they're needed.
- **Don't duplicate memory.** If something fits as a CC memory entry (small, atomic,
  per-project), use memory. Knowledge is for structural understanding that's too
  big or too cross-cutting for memory.
- **Don't duplicate repo docs.** If the repo has good architecture docs, don't
  copy them into knowledge. Reference them instead.
- **Capture requires explicit intent.** Never auto-save to knowledge. The user
  must ask for it — this prevents knowledge bloat.
- **Keep notes concise.** A knowledge note should reduce rediscovery cost, not
  replace reading the code. Target 50-150 lines per note.
