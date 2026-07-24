# Local AI implementor — how it works

How the local model is configured on this machine, and how Claude Code hands implementation work to it. Claude Code is the **architect** (plans, writes specs, reviews diffs); the local model is the **implementor** (edits files autonomously, offline, at zero API cost). Everything below is installed by `./install.sh --with-localai`.

## The three moving parts

### 1. Runtime — Ollama

- Start once per boot: `brew services start ollama`.
- Models run on the llama.cpp Metal backend (100% GPU on Apple Silicon).
- **Context is the footgun**: Ollama defaults to 4K and silently truncates, which breaks agent loops. The fix is baked into the models themselves via a Modelfile (`PARAMETER num_ctx 65536`, plus `temperature 0.2` and `top_p 0.95`) — env-var overrides proved unreliable.
- Health check: `ollama ps` should show **100% GPU** and **65536** context.

### 2. Models

| Model | Role | How to use |
|---|---|---|
| `devstral-small-2:24b` | Default implementor (reliable tool-calling) | automatic — no flag needed |
| `qwen3.6-35b-a3b` | Benchmark challenger (faster, less proven) | pass `-m ollama/qwen3.6-35b-a3b` |

Both local models are rebuilt with `ollama create <name> -f Modelfile` so the 65536 context is guaranteed.

**Cloud tier (Ollama Cloud Pro, $20/mo, 3 concurrency slots)** — with `ollama signin`, three smoke-test-validated `:cloud` models run through the same local endpoint, ~3–4× faster than local Devstral, still zero Anthropic API cost:

| Model | Role | How to use |
|---|---|---|
| `glm-5.2:cloud` | Architect/reviewer, hard tier — daily default | `cc-review` default; `opus`/`fable` alias via `cc-ollama` |
| `kimi-k2.7-code:cloud` | Equal-speed fallback when GLM is down/rate-limited | `cc-review -k`; `custom` picker row via `cc-ollama` |
| `deepseek-v4-flash:cloud` | Fast cross-family reviewer (different lineage → fewer shared blind spots) | `cc-review -d`; OpenCode `-m ollama/deepseek-v4-flash:cloud` |

### 3. Harness — OpenCode

`brew install opencode`. Config lives in the tracked, symlinked `.config/opencode/opencode.json`:

- **Provider**: `ollama` via `@ai-sdk/openai-compatible` pointed at `http://localhost:11434/v1`.
- **Default model**: `ollama/devstral-small-2:24b` — so plain `opencode run "…"` uses Devstral.
- **Global permissions**: `edit: allow`, `bash: ask`, `webfetch: deny`.
- **Agent profiles** `implement` and `explore`: bash is default-**allow** with a hard **deny-list** (`sudo`, `rm -rf`, `git commit/push/reset/clean`, `curl`/`wget`/`ssh`/`scp`, `npm publish`, and destructive `kubectl`/`gcloud`/`aws`/`gh` subcommands). No "ask" rules anywhere, so headless runs never stop at a prompt and need no bypass flag. Denied commands don't kill the run — the model is told and continues.

OpenCode **never commits** — the diff always sits uncommitted in the working tree for review.

## How Claude Code knows to hand off

Two triggers, both wired into this repo:

1. **Trigger phrase** — after a plan is agreed in chat, say `let devstral implement`, `let qwen implement`, or just `implement`. This invokes the `local-implementor` skill at `.claude/skills/local-implementor/SKILL.md` (reaches `~/.claude/skills/` via the whole-directory symlink, so it works in every repo).
2. **Automode (plan approval)** — the `cc-plan-handoff` hook (`~/.scripts/cc-plan-handoff`, registered in `.claude/settings.json` as a PostToolUse hook on `ExitPlanMode`) fires the moment you approve a plan in plan mode. It makes Claude ask: **Devstral (local)** / **Qwen (local)** / **Claude** — no trigger phrase needed. Picking Claude just implements normally.

The hook is a no-op on machines without `opencode` + `ollama` installed, so the tracked config is safe everywhere.

## What happens during a handoff

1. Claude slices the agreed plan into **one task per run** (small models follow short specs much better).
2. For each task Claude writes a self-contained spec (`.task-spec.md`): exact file paths, an exhaustive `## Allowed files` list, and concrete verify commands.
3. Claude runs `opencode run --agent implement "$(cat .task-spec.md)"` in the background and narrates progress in chat.
4. **Review**: Claude first runs a deterministic scope gate (`git status --porcelain` compared against the allow-list — the model's own summary is never trusted), then checks the diff and runs the spec's verify commands itself.
5. Problems become a `# Fix round N of 3` spec and the run repeats — max 3 rounds, then Claude fixes trivial leftovers by hand.
6. The spec is deleted; the diff is **left uncommitted** for you to review and commit with `git cz`.

## Watching a run

- `cc-impl-status` (or `! cc-impl-status` inside a Claude chat) — RUNNING/STALE/FINISHED + log tail; `-f` follows.
- tmux `prefix+o` — popup tailing the live run log.
- The Claude Code statusline shows `impl ●7m r2` while a run is active.
- Raw state: `~/.claude/cache/impl/<hash>/` (`state` + `run.log`), kept after the run as a post-mortem.

## Reviewing without a paid advisor (`cc-review`)

The stronger cloud model reviews the weaker implementor's diff, at zero API cost: `cc-review` pipes `git diff HEAD` (or a file, or stdin via `-`) to `glm-5.2:cloud` and prints the critique. Flags: `-k` kimi (equal-speed fallback), `-d` deepseek (cross-family second opinion), `-l` local Devstral (free fallback when cloud quota is exhausted), `-m "focus"` for a one-line focus. This closes the loop: Claude architects, Devstral implements, GLM reviews — no Anthropic API spend anywhere.

## Safety model

The deny-list is harm reduction, not a sandbox. The real backstops are layered: OpenCode never commits, every edit is git-recoverable, and Claude reviews every diff before you commit. Hands-free operation on the Claude side is granted by explicit allow rules in the machine-local `~/.claude/settings.local.json` (`opencode run --agent implement:*`, `Write(.task-spec.md)`, `rm .task-spec.md`).
