# Profile: work-windows

## Environment
- OS: Windows
- Hosts: Codex only (no Claude Code)
- Network: restricted (GitHub HTTPS read-only, no upstream git clones)

## Upstreams
- gstack: unavailable (banned software policy prevents installation of upstream repos)

## Custom Skills & Knowledge
- Work-specific custom skills tailored to internal tooling
- Domain knowledge for internal APIs and services
- Work-specific AGENTS.md with rules for internal codebases

## Sync Strategy
- Manual reference from GitHub (no automated push/pull)
- Read profiles and inventory on GitHub to understand what the setup should look like
- Apply configuration manually based on profile documentation

## Shared with Reference Machine
- Same philosophy and principles (PHILOSOPHY.md)
- Same repo as single source of truth (read from GitHub)

## Differences from Reference Machine
- Codex only (no Claude Code)
- No gstack upstream (banned software policy)
- No automated sync.sh workflow (restricted network)
- Different AGENTS.md with work-specific rules and domain knowledge
- Windows OS instead of macOS
- Domain-specific knowledge base not present in personal setup

## Workarounds for Missing Upstreams
- gstack: work-specific custom skills fill the gap for workflow automation. The skills available through gstack (like /retro, /ship, /browse) are replaced by manual processes or work-specific alternatives where needed. Vendoring gstack into the repo for manual deployment is a future design problem — for now, the constraint is documented and accepted.
