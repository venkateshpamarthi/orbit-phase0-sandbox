# Agent Development Guide

This repository is the Phase 0 and Phase 2 engineering sandbox for ORBIT's workflow conventions.

## Running Checks Locally

To run all checks locally before pushing:

```bash
./scripts/check.sh
```

This runs the test suite and performs other validation checks.

## Branch Naming Convention

Branch names follow this pattern: `<issue-id>-<hyphenated-title>`

- Issue ID is lowercased and appears at the start
- Title is lowercased with non-alphanumeric characters replaced by single hyphens
- No leading or trailing hyphens

Use the helper script to generate branch names:

```bash
./scripts/branch_name.sh <issue-id> <title words...>
```

Example:
```bash
./scripts/branch_name.sh VEN-15 Add AGENTS.md, ADR-0001, and a tested branch-name helper
# Outputs: ven-15-add-agents-md-adr-0001-and-a-tested-branch-name-helper
```

## Pull Request Wording

PR bodies must use `Refs <issue-id>` to reference the associated issue.

**Never use closing keywords** like `Fixes`, `Closes`, `Resolves`, or `Completes` in PR bodies, as these may trigger unintended status changes in connected issue trackers.

Example PR body:
```
Refs VEN-15
```

## Architecture Decision Records

Architecture decisions are documented in the `/adr` directory as individual markdown files following the naming pattern `adr/NNNN-<short-slug>.md`.

Each ADR should:
- Record a specific decision made during development
- Link to the associated issue and PR
- Explain the context, decision, and consequences
- Not duplicate issue or PR content (link instead)
