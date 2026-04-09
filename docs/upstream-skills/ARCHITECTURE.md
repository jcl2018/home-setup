---
type: architecture
feature: upstream-skills
title: "Upstream Skills — Architecture"
version: 1
status: Active
date: 2026-04-09
author: chjiang
prd: PRD.md
---

## Overview

Upstream skill management implements P2 (copies, not forks) through a catalog-driven registry and a clean-overwrite sync model. The catalog (`skills-catalog.json`) is the single source of truth for what upstream skills exist, their dependencies, and their version. Deploy copies them to `~/.claude/skills/gstack/`.

## Architecture

```
gstack repo (upstream)         home-setup repo              ~/.claude/
+------------------+    git   +---------------------+       +------------------+
| skills/          | --pull-> | skills/{name}/      |       |                  |
| VERSION          |          | SKILL.md (per skill)|--deploy-->| skills/gstack/   |
+------------------+          +---------------------+       +------------------+
                              | skills-catalog.json |
                              | (registry: version, |
                              |  deps, portability) |
                              +---------------------+
                                       |
                              audit check 1.7: version compare
```

### Components Affected

| Component | Path | Change Type | Description |
|-----------|------|------------|-------------|
| Skill catalog | skills-catalog.json | Core | Registry with upstream version, deps, portability per skill |
| Upstream skills | skills/{name}/SKILL.md | Managed | Direct copies from gstack, never edited locally |
| Bin scripts | skills/bin/*.sh | Managed | Shell helpers some skills depend on |
| Deploy script | scripts/deploy.sh | Integration | Copies skills/ to ~/.claude/skills/gstack/ |

### Data Flow

1. Owner pulls latest gstack repo into a working copy
2. Owner copies updated SKILL.md files into skills/{name}/
3. Owner updates version in skills-catalog.json
4. deploy.sh copies skills/ to ~/.claude/skills/gstack/
5. Audit check 1.7 compares catalog version against upstream VERSION file

## Design Decisions

| Decision | Chosen | Rejected Alternative | Why |
|----------|--------|---------------------|-----|
| Clean overwrite sync | Copy SKILL.md files wholesale | Git submodule or subtree | Simpler; no merge conflicts; P2 compliance by construction |
| Catalog as registry | JSON with version + deps + portability | Directory listing only | Enables audit checks, dependency validation, and doc generation |
