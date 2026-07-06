---
name: document-new-feature-or-workflow
description: Workflow command scaffold for document-new-feature-or-workflow in dotfiles.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /document-new-feature-or-workflow

Use this workflow when working on **document-new-feature-or-workflow** in `dotfiles`.

## Goal

Documents a new feature, workflow, or configuration in the project, often after implementation.

## Common Files

- `README.md`
- `CLAUDE.md`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Implement or integrate the new feature/tool/workflow.
- Update or create documentation files (e.g., README.md, CLAUDE.md) to explain usage, setup, and operational notes.
- Commit documentation changes with a message referencing the new feature/workflow.

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.