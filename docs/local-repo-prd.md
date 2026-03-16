# PRD: Local Repo Support In Home Setup

## Summary

This document defines the product intent for the local-repo portion of the home setup reference repo. The goal is to make local repository work more consistent and easier to onboard without turning the home setup into a repo-specific handbook.

## Problem

Without a shared home-level workflow, local repo work becomes noisy and inconsistent:

- startup habits differ from repo to repo
- useful reusable workflows get lost in long global instructions
- repo contracts are often missing or bloated
- verification is easy to skip or rediscover repeatedly
- unfinished work is harder to resume cleanly

The home setup should fix the cross-repo workflow problems while leaving repo-specific technical truth inside each repo.

## Users

- Primary user: the owner of this home setup working across multiple local repos
- Secondary user: a future Codex session or another machine adopting the same workflow model

## Goals

- Define a repeatable way to start work in a local repo
- Make it obvious when to use the `lv1-workflow-*` skills
- Reinforce that each repo owns its own `AGENTS.md`, verification commands, and architecture details
- Reduce setup drift across repos by making the home-level workflow explicit
- Help a new machine understand how local repos fit into the home setup design

## Non-Goals

- Document stack-specific toolchains for every language or framework
- Replace per-repo documentation or architecture notes
- Standardize one required location for all repos beyond the current reference preference
- Automate repo scaffolding for every project type from this home repo alone

## User Stories

- As a user starting work in a repo, I want a short repeatable checklist so I can get oriented quickly.
- As a user creating or onboarding a repo, I want clear guidance on when to use the repo bootstrap and project contract skills.
- As a user returning to unfinished work, I want handoff conventions that reduce rediscovery.
- As a user on a new machine, I want to understand how local repo workflow fits into the broader home setup.

## Requirements

### Documentation

- The repo must include a local repo workflow guide that explains:
  where repos typically live on the reference machine, how to start work, how to identify verification early, and the boundary between home-level and repo-level rules.
- The repo must include this PRD so the local repo support intent is explicit.
- The README should link to the local repo workflow material.

### Skill Integration

- The docs must explain the intended role of:
  `lv1-workflow-repo-bootstrap`,
  `lv1-workflow-project-contract`,
  `lv1-workflow-repo-knowledge-capture`,
  `lv1-workflow-session-handoff`.
- The docs must clarify that these are reusable workflows, not replacements for repo-local truth.

### Adoption

- The repo must explain the local repo workflow as part of the overall home setup reference model.
- A new machine should be able to learn the intended local repo workflow from the docs without needing to inspect every skill file directly.

## Acceptance Criteria

- A reader can identify the recommended repo startup flow from the docs alone.
- A reader can tell which skills help with local repo work and when to use them.
- A reader can tell that repo-specific build, test, and architecture rules belong in each repo, not in this home repo.
- The README links to the local repo workflow guide and this PRD.

## Success Signal

The local repo section of the home setup is successful if future work in a new or existing repo starts with less rediscovery and fewer ad hoc workflow decisions.
