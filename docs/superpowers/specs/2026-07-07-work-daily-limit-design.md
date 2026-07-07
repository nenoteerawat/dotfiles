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
- **All work-account configuration follows the cc-auth model.** No user-level
  config file: the daily budget lives in `~/.claude/work-auth.json` and is
  stamped into each work repo's `.claude/settings.local.json` by
  `cc-auth work`, exactly like the credentials.
- The existing Cost API plumbing (`cc-credits-refresh`, monthly `acct`
  segment, `spent_today` cache field) stays unchanged — it remains the monthly
  org view, dormant until an Admin key is ever supplied.

## Budget configuration — follows cc-auth, no user-level file

`WORK_DAILY_BUDGET` (e.g. `"100"`) is added as one more entry in
`~/.claude/work-auth.json` — the same JSON object that holds the work
credentials. Because `cc-auth` reads the work env block dynamically from that
file ("the block can grow/shrink without editing this script"), **cc-auth
needs no code change**:

- `cc-auth work` stamps `WORK_DAILY_BUDGET` into the repo's
  `.claude/settings.local.json` `env` block alongside the key/gateway/header.
- `cc-auth personal` strips it with the rest of the work block.
- `install.sh` seeds the new field in the `work-auth.json` template.
- **Migration note:** repos stamped before this change won't have the budget
  until `cc-auth work` is re-run in them (stamping merges, so a re-run is
  safe). Until then the default below still protects them.

## Work-account detection (billing-accurate, env-based)

Claude Code injects the settings `env` block into its process environment, and
the statusline and hooks run as child processes, so they inherit it:

- **Work session** ⇔ `ANTHROPIC_API_KEY` is set in the inherited environment
  (billing truth: that is the variable that makes the session bill the work
  gateway). Subscription (personal) sessions are never tracked and never
  blocked.
- **Budget** = `$WORK_DAILY_BUDGET` if set and numeric, else **default 100**
  (protects work repos stamped before the budget field existed).
  `WORK_DAILY_BUDGET=0` disables the segment thresholds and all enforcement
  (escape hatch, set per-repo via work-auth.json or a hand edit).

Detection cost: two env-var checks — effectively free, no file reads.

**Verification gate (implementation step 1):** confirm with a throwaway hook +
statusline echo that both actually inherit `env`-block variables. If either
does not, fall back for that component to reading
`.env.ANTHROPIC_API_KEY` / `.env.WORK_DAILY_BUDGET` from
`<repo-top>/.claude/settings.local.json` via `jq` (cwd comes from the
component's stdin JSON; guarded, a few ms).

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
The budget comes from the inherited `$WORK_DAILY_BUDGET` (see above) — the
statusline still never opens any secret file.

## Component 3 — enforcement hook (`.scripts/cc-work-limit`)

One bash script (new file in `.scripts/`, instantly on `$PATH` via the
whole-dir symlink), registered in the tracked `~/.claude/settings.json` for
two events. Logic per invocation:

1. If `ANTHROPIC_API_KEY` is not in the environment → exit 0 (fast path:
   personal session, no output, no file reads).
2. Resolve budget from `$WORK_DAILY_BUDGET` (default 100; 0 → exit 0).
3. Parse hook stdin JSON (`hook_event_name`) with `jq` (exit 0 if `jq`
   missing); sum today's ledger.
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

- Env inheritance gate first (see verification gate above).
- Statusline: `ANTHROPIC_API_KEY=x WORK_DAILY_BUDGET=100 bash -c "echo '<fake status JSON with cost + session_id>' | ~/.claude/statusline.sh"`
  vs the same without the env vars; verify the ledger file appears only in the
  work case and the `day` segment renders with correct colors at <80%, ≥80%,
  ≥100%.
- Ledger monotonicity: render twice with a lower second cost; file keeps max.
- Hook: pipe fake `UserPromptSubmit` / `PreToolUse` JSON into `cc-work-limit`
  with a ledger seeded at $85 and $105 and the env vars set; assert warn JSON,
  block JSON, and deny JSON respectively; assert silent exit 0 without
  `ANTHROPIC_API_KEY` and with `WORK_DAILY_BUDGET=0`.
- End-to-end: set `WORK_DAILY_BUDGET` to `1` in a work repo's
  `.claude/settings.local.json`, start a Claude Code session there, confirm
  the prompt block fires; restore afterwards.

## Out of scope

- Cost API / Admin key work (existing dormant path unchanged).
- Tracking usage from other machines or non-Claude-Code API usage.
- `cc-acct` / display-toggle changes.
