---
name: update-configuration-and-documentation-in-tandem
description: Workflow command scaffold for update-configuration-and-documentation-in-tandem in dotfiles.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /update-configuration-and-documentation-in-tandem

Use this workflow when working on **update-configuration-and-documentation-in-tandem** in `dotfiles`.

## Goal

Updates configuration files and immediately documents the changes in project documentation.

## Common Files

- `.config/opencode/opencode.json`
- `install.sh`
- `CLAUDE.md`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Edit or add configuration files (e.g., .config/opencode/opencode.json, install.sh).
- Update documentation files (e.g., CLAUDE.md) to reflect the new configuration or installation steps.
- Commit both configuration and documentation changes together.

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.