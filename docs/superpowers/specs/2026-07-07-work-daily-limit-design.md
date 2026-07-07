# Work-account $100/day spend limit — design

**Date:** 2026-07-07
**Status:** approved

## Problem

The work account has a hard usage policy of **$100/day**. Today the statusline
only shows month-to-date org spend via the Anthropic Cost API — and that
segment is dormant (requires an Admin key; only a regular key exists). There is
no daily figure the user can watch, and nothing stops a session from spending
past the policy limit.

## Decisions (made with the user)

- **Data source: local ledger.** Spend is measured from Claude Code's own
  session cost data on this machine (statusline stdin JSON), not the Cost API.
  No Admin key needed, no ~5-minute lag, so enforcement is real-time.
  Trade-off (accepted): only counts Claude Code usage on this Mac.
- **Enforcement: warn at 80%, hard block at 100%.**
- The existing Cost API plumbing (`cc-credits-refresh`, monthly `acct`
  segment, `spent_today` cache field) stays unchanged — it remains the monthly
  org view, dormant until an Admin key is ever supplied.

## Work-account detection (billing-accurate)

A session bills the work API iff the current repo's
`.claude/settings.local.json` (as stamped by `cc-auth work`) contains
`ANTHROPIC_API_KEY`. This — not the `cc-acct` display toggle — gates both the
ledger recording and the hook. Subscription (personal) sessions are never
tracked and never blocked.

Detection cost: resolve repo top with `git rev-parse --show-toplevel`, check
the file exists, one `jq -e` for the key. All guarded, a few ms.

## Component 1 — spend ledger (recorded by the statusline)

`~/.claude/statusline.sh` already receives `session_id` and cumulative
`cost.total_cost_usd` on every render (debounced 300 ms). For work-billed
sessions it writes the cost to:

```
~/.claude/cache/work-day/<YYYY-MM-DD>/<session_id>
```

- **Monotonic:** only rewrite when the new value is greater than the stored
  one (cost is cumulative per session, so this is just "value grew").
- **Race-free:** one file per session, single writer — no locking needed.
- **Local dates** (`date +%F`): the limit resets at local midnight
  (Asia/Bangkok), matching the human notion of "per day".
- **Midnight-spanning sessions** double-count their pre-midnight cost onto the
  new day. Conservative (blocks earlier, never later) and rare — accepted.
- Today's total = `awk` sum over the files in today's dir.

## Component 2 — statusline `day` segment

For work-billed sessions, a new segment renders today's ledger total against
the daily budget:

```
day $37/$100
```

Color escalation matches the hook thresholds: default foreground, **yellow at
≥ 80%**, **bright red at ≥ 100%**. Rendered whenever the session is
work-billed, independent of the (possibly dormant) monthly `acct` segment.

### Budget configuration — `~/.claude/work-limit.conf`

Non-secret, optional, sourced by both the statusline and the hook:

```sh
WORK_DAILY_BUDGET=100
```

Default is **100** when the file is absent. `WORK_DAILY_BUDGET=0` disables
both the segment's coloring thresholds and all hook enforcement (escape
hatch). Kept separate from `statusline-credits.env` to preserve the invariant
that **the statusline never opens the file containing the Admin key**.
`install.sh` seeds this file (non-600, it holds no secret) alongside the
existing credential template.

## Component 3 — enforcement hook (`.scripts/cc-work-limit`)

One bash script (new file in `.scripts/`, instantly on `$PATH` via the
whole-dir symlink), registered in the tracked `~/.claude/settings.json` for
two events. Logic per invocation:

1. Parse hook stdin JSON (`cwd`, `hook_event_name`) with `jq` (exit 0 if `jq`
   missing).
2. If the `cwd` repo is not work-billed → exit 0 (fast path, no output).
3. Sum today's ledger; read `WORK_DAILY_BUDGET` (0 → exit 0).
4. Emit per event:

| Event | Condition | Output |
|---|---|---|
| `UserPromptSubmit` | total ≥ 100% | `{"decision":"block","reason":"…"}` — prompt rejected, message tells the user the $100/day work budget is spent and suggests `cc-auth personal` or waiting for local midnight |
| `UserPromptSubmit` | 80% ≤ total < 100% | exit 0 + `{"systemMessage":"⚠ work spend today $X of $Y"}` — warning shown to the user, prompt proceeds |
| `PreToolUse` (all tools) | total ≥ 100% | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"…"}}` — stops a long-running turn mid-flight (ledger keeps updating during a turn because the statusline keeps rendering) |
| anything else | — | exit 0 |

5. Housekeeping: prune `work-day` dirs older than 14 days (done here, once
   per prompt, so the statusline stays write-only fast).

### settings.json registration

Append to the existing `UserPromptSubmit` hooks array and add a `PreToolUse`
entry (matcher `""` = all tools), both invoking
`$HOME/.scripts/cc-work-limit`. The existing tmux state hooks are untouched.

## Error handling

- Every external read (`jq`, missing files, malformed numbers) is guarded;
  any failure degrades to "no tracking / no blocking", never to a broken
  statusline or a hook error that stalls Claude Code.
- The hook never blocks personal sessions even if ledger files are corrupt —
  work detection happens before any ledger read.

## Testing

- Statusline: `echo '<fake status JSON with cost + session_id>' | ~/.claude/statusline.sh`
  from a work-stamped repo dir and a personal dir; verify ledger file appears
  only for work and the `day` segment renders with correct colors.
- Ledger monotonicity: render twice with a lower second cost; file keeps max.
- Hook: pipe fake `UserPromptSubmit` / `PreToolUse` JSON into
  `cc-work-limit` with a ledger seeded at $85 and $105; assert warn JSON,
  block JSON, and deny JSON respectively; assert silent exit 0 in a personal
  repo and with `WORK_DAILY_BUDGET=0`.
- End-to-end: temporarily set `WORK_DAILY_BUDGET=1` in `work-limit.conf`,
  start a Claude Code session in a work repo, confirm the prompt block fires.

## Out of scope

- Cost API / Admin key work (existing dormant path unchanged).
- Tracking usage from other machines or non-Claude-Code API usage.
- `cc-acct` / display-toggle changes.
