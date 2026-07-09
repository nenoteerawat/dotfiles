---
name: local-implementor
description: Use when the user wants an agreed implementation plan executed by the local model (OpenCode + Ollama, zero API cost) — "let devstral implement" / "yes let devstral implement" / "let qwen implement" / "implement with devstral" / "implement with qwen" / "implement with the local model" / "delegate to local model", plain "implement" after a plan has been agreed in chat, or when the cc-plan-handoff hook injects its automode note right after the user approves a plan.
---

# local-implementor — delegate implementation to a local model

You are the **architect**; the local model (OpenCode + Devstral or Qwen) is the **implementor**. Your job: slice the agreed plan into per-run task specs the local model can execute blind, run them sequentially, gate + review each diff, and loop fixes — max 3 rounds per task. You never implement the plan yourself unless the loop is exhausted or the user tells you to.

## Prerequisites

- A plan must already be agreed in this conversation. If the user asks to implement with no agreed plan, first pin down what to build (files, behavior, acceptance criteria) before starting.
- Fully hands-free operation needs the user's explicit allow rules in `~/.claude/settings.json`: `Bash(opencode run --agent implement:*)`, `Write(.task-spec.md)`, `Bash(rm .task-spec.md)`. Without them the flow still works but pauses at permission prompts — that is expected, not an error; never try to bypass a prompt or denial.

## Model selection

Pick the model from the user's words:

- **"devstral"** or no model named → Devstral (the default; no `-m` flag).
- **"qwen"** → Qwen: append `-m ollama/qwen3.6-35b-a3b` to the run command. First check it exists (`ollama ls | grep -i qwen3.6`); if missing, tell the user it must be built from the downloaded blob via a Modelfile (see the dotfiles CLAUDE.md "Local AI coding implementor" section — a direct hf.co pull 400s on import) and ask whether to fall back to Devstral. **Backend caveat:** Qwen tool-call failures under Ollama are usually the serving/template layer, not the model (stripped chat templates, Hermes-JSON-vs-XML mis-wiring; version-sensitive) — if a Qwen run ends with no file edits or tool-call parse errors, diagnose it as a backend problem: fall back to Devstral for the task and tell the user, don't burn fix rounds re-prompting Qwen.

## Automode entry (plan approval)

The `cc-plan-handoff` hook (PostToolUse on `ExitPlanMode`, registered in the tracked `.claude/settings.json`) injects an automode note the moment the user approves a plan — that note triggers this skill exactly like the phrases above. When it appears:

- The user already picked an implementor while planning (named devstral or qwen, or asked Claude to implement) → skip the question and honor that choice.
- Otherwise ask with AskUserQuestion — question: "Who should implement this plan?", header "Implementor", options: **Devstral (local) (Recommended)**, **Qwen (local)**, **Claude** (implement directly).
- Devstral or Qwen chosen → continue with this skill exactly as if the user had said "let <model> implement".
- Claude chosen → this skill ends here; implement the plan normally.
- The hook fires only on machines with the local stack installed, but preflight (below) still applies — on preflight failure follow its remedy path, never silently fall back.

## Procedure

### 1. Preflight

Check the environment:

- `command -v opencode` — if missing: `brew install opencode`.
- `curl -sf --max-time 2 http://localhost:11434/api/version` — if unreachable: `brew services start ollama`.

On failure, report the exact remedy and ask the user whether to fix the environment or fall back to implementing directly in Claude Code. **Never silently fall back** — zero-cost local delegation is the point of this flow.

### 2. Write the spec — one task per run

**Slice the plan first.** Instruction adherence drops as a spec grows ("curse of instructions" — worse on a small local model), so a multi-task plan becomes multiple sequential runs: write the spec for task 1, run, review, then write the spec for task 2, and so on. Batch tasks into one spec only when they are too small to review separately; interdependence is not a reason to batch — a later task's spec states what the earlier run produced (exact signatures) as context.

Write the current task's spec to `.task-spec.md` at the **target repo root**. Spec quality rules — the local model sees nothing of this chat, so the spec must stand alone:

- **Self-contained**: all context needed is in the spec; no references to "the plan above" or this conversation.
- **Exact file paths** for every file to create or change, with what changes in each.
- **Concrete acceptance criteria**, including the exact test/verify command(s) to run and their expected output.
- **`## Allowed files` section**: the complete allow-list of files this run may create or modify. This is the review gate in step 4, so it must be exhaustive; an extra "do not touch" note for risky neighbors is fine, but the allow-list is what gets enforced.
- **Closing self-verification instruction** as the spec's last section: "After implementing, re-read this spec and check every requirement; list any item not fully met."
- Durable repo-wide conventions belong in the target repo's `AGENTS.md` (OpenCode auto-loads it) — never repeat them per-spec; create/extend `AGENTS.md` if a convention will matter beyond this task (see below).

**AGENTS.md rules** (when creating or extending it):

- Minimal and curated: only non-inferable conventions — exact commands, layout quirks, style rules the code itself doesn't show. Kitchen-sink or auto-generated repo overviews measurably hurt agents (>20% more cost, no success gain, and agents faithfully follow even the useless rules).
- Cover at most: commands, testing, structure, style, git workflow, boundaries. Express boundaries in three tiers — always / ask-first / never ("ask-first" is enforced by the opencode.json permission config in headless runs, not by asking).
- **Fallback gotcha:** once `AGENTS.md` exists, OpenCode ignores the repo's `CLAUDE.md` entirely (fallback, not additive). When creating `AGENTS.md` in a repo that has a `CLAUDE.md`, port every convention the implementor needs — this step is mandatory, not optional.

### 3. Run the implementor

From the target repo root, run via Bash with `run_in_background: true` (Devstral decodes ~21 tok/s, so nontrivial tasks exceed the 10-minute foreground cap):

Every run goes through the **status wrapper** so the run is observable (statusline `impl` segment, `cc-impl-status`, tmux `prefix+o`, and your own narration all read its files). Substitute `MODEL` (`devstral`|`qwen`), `TASK_LABEL` (short human label, chars `[A-Za-z0-9 ._-]` only), `ROUND` (1–3), and add the `-m` flag only for qwen:

```bash
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
IMPL_DIR="$HOME/.claude/cache/impl/$(printf '%s' "$root" | md5sum | cut -c1-8)"
mkdir -p "$IMPL_DIR"
printf 'pid=%s\nstarted=%s\nmodel=%s\ntask=%s\nround=%s\nrepo=%s\n' \
  "$$" "$(date +%s)" "MODEL" "TASK_LABEL" "ROUND" "$root" > "$IMPL_DIR/state"
set -o pipefail
opencode run --agent implement "$(cat .task-spec.md)" 2>&1 | tee "$IMPL_DIR/run.log"
ec=$?
printf 'ended=%s\nexit=%s\n' "$(date +%s)" "$ec" >> "$IMPL_DIR/state"
exit "$ec"
```

(`pipefail` keeps the exit code truthful through the `tee`; the `ended=`/`exit=` append happens even while you sleep, so the files are always self-describing. Each round rewrites `state` and truncates `run.log`. If `md5sum` is missing, fall back to running `opencode run` bare — observability is optional, the run is not.)

**No permission-bypass flag** — the `implement` agent profile in `~/.config/opencode/opencode.json` has no "ask" rules: bash is default-allow with destructive/exfil commands (`sudo`, `rm -rf`, `git commit/push`, `curl`, cloud-CLI deletes, …) hard-denied, so headless runs are prompt-free by construction. Denials don't stall the run — the model is told and continues. If a run ever does stall on an unexpected permission, that's a profile gap: kill it, surface it to the user, don't bypass it.

**While it runs, narrate.** Don't wait silently: check the run every ~2–3 minutes (Monitor with a ~150 s timeout, or equivalent short waits). Each wake, read the fresh tail of `"$IMPL_DIR/run.log"`, strip ANSI escapes (`sed -E $'s/\\x1b\\[[0-9;]*[A-Za-z]//g'`), and post **exactly one line** to the user: elapsed + model + round + latest activity, e.g. `⏱ 6m · devstral r1 — edited src/foo.ts, now running npm test`. If the user asks for status at any point, answer the same way from `state` + the log tail (or run `cc-impl-status`). If it is still running after ~30 minutes, kill it precisely via the wrapper pid from "$IMPL_DIR/state" (pkill -P <that pid> — kills the wrapper's children so the wrapper still appends ended=/exit=); never a machine-global pkill -f 'opencode run' (it would collateral-kill a parallel run in another repo) and never just the wrapper shell (that orphans opencode). Treat the round as failed. Note: the first run after ~5 min idle pays a one-time ~8 s model load. A fresh directory's first run may also stay silent for a minute or two while opencode bootstraps its instance — report the silence honestly rather than treating it as a hang.

### 4. Review

**Scope gate first — deterministic, before reading any code:** in the target repo run `git status --porcelain` and compare every changed/created path against the spec's `## Allowed files` list. Any path outside the list is an automatic fix-round problem (or revert it yourself if trivial), no matter what the tests say — the local model can restate a file-scope rule and still violate it while producing passing tests, so spec wording is guidance and this gate is the enforcement.

Then `git diff` and:

- Check **every acceptance criterion** from the spec against the actual diff.
- Run the spec's test/verify command(s) yourself and read the output — the implementor's completion summary is never evidence.
- Flag reverted unrelated code and edits that are in-scope files but out-of-spec changes.

### 5. Fix loop (max 3 rounds per task, including the task's first run)

If review finds problems, overwrite `.task-spec.md` with a **focused fix spec**:

- Header: `# Fix round N of 3`.
- One bullet per problem: `file:line`, the observed wrong behavior, the required behavior.
- Carry the `## Allowed files` list forward unchanged (plus any file legitimately discovered to be needed).
- End with: "Keep all other changes from the previous round; do not start over."

Then repeat steps 3–4 (same model). After round 3: fix trivial residuals directly in Claude Code yourself; for anything larger, stop and report what remains.

### 6. Finish

- `rm .task-spec.md` (transient handoff artifact — never leave it in the tree).
- Report: which model implemented, rounds used, what was implemented, test results, anything you fixed by hand, anything left open.
- State explicitly that the diff is **uncommitted** and the user reviews/commits with `git cz`.
- **NEVER commit or push.** The guardrails deny the implementor `git commit`; the same rule binds you in this flow.
