#!/usr/bin/env bash
# Clear Dark "Beacon" status line for Claude Code.
# Flat, text-only, translucent-friendly. Complements starship + tmux:
# surfaces only what is Claude-specific (model, context %, cost, lines)
# plus the persistent personal/PTTEP work identity badge.

# --- Clear Dark palette (truecolor foregrounds) ---
C_FG=$'\033[38;2;224;224;224m'      # #E0E0E0 primary value text
C_DIM=$'\033[38;2;70;92;109m'       # #465C6D labels / separators
C_BLUE=$'\033[38;2;103;181;237m'    # #67B5ED loud accent (model)
C_BLUE2=$'\033[38;2;109;150;180m'   # #6D96B4 calm accent
C_YEL=$'\033[38;2;196;172;98m'      # #C4AC62 warn / work badge
C_GRN=$'\033[38;2;108;170;113m'     # #6CAA71 added
C_RED=$'\033[38;2;180;86;72m'       # #B45648 removed
C_BRED=$'\033[38;2;223;108;90m'     # #DF6C5A error / critical
R=$'\033[0m'

SEP="${C_DIM} │ ${R}"

# --- read stdin once ---
input=$(cat)

# --- jq guard: degrade to a plain model line if jq is missing ---
if ! command -v jq >/dev/null 2>&1; then
  printf '%b\n' "${C_BLUE}Claude${R}"
  exit 0
fi

# helper: jq getter with default
get() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

model=$(get '.model.display_name // "Claude"')
[[ -z "$model" ]] && model="Claude"
cwd=$(get '.workspace.current_dir // .cwd // ""')
cost=$(get '.cost.total_cost_usd // 0')
added=$(get '.cost.total_lines_added // 0')
removed=$(get '.cost.total_lines_removed // 0')
ctx_pct=$(get '.context_window.used_percentage // empty')
ctx_size=$(get '.context_window.context_window_size // 200000')

# --- shorten cwd: ~/.ghq/github.com/<org>/<repo> -> <org>/<repo>; $HOME -> ~ ---
short_cwd="$cwd"
ghq_prefix="$HOME/.ghq/github.com/"
if [[ "$short_cwd" == "$ghq_prefix"* ]]; then
  short_cwd="${short_cwd#"$ghq_prefix"}"
elif [[ "$short_cwd" == "$HOME"* ]]; then
  short_cwd="~${short_cwd#"$HOME"}"
fi

# --- git (cheap plumbing, all guarded) ---
# Guard against empty/absent cwd: git -C "" operates on the script's process
# CWD and would leak an unrelated repo's branch, so require a real directory.
branch="" dirty="" ahead="" behind="" badge="" remote=""
if [[ -n "$cwd" && -d "$cwd" ]] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ "$branch" == "HEAD" ]] && branch="detached"

  # dirty check (porcelain, no optional locks)
  if [[ -n $(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null) ]]; then
    dirty="*"
  fi

  # ahead/behind vs upstream (single rev-list)
  ab=$(git -C "$cwd" rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
  if [[ -n "$ab" ]]; then
    behind=${ab%%$'\t'*}
    ahead=${ab##*$'\t'}
    [[ "$ahead" == "0" ]] && ahead=""
    [[ "$behind" == "0" ]] && behind=""
  fi

  # work/personal identity badge from remote (no network)
  remote=$(git -C "$cwd" config --get remote.origin.url 2>/dev/null)
fi

# badge also falls back to path org segment
if [[ "$remote" == *github.com-pttep* || "$remote" == *pttep-pcl* || "$remote" == *pttep-fusionsol* \
   || "$short_cwd" == pttep-pcl/* || "$short_cwd" == pttep-fusionsol/* ]]; then
  badge="${C_YEL} work${R}"
fi

# ================= assemble single flat line =================
out="${C_BLUE}${model}${R}"

# path (doubles as work/personal context; only the org/repo form)
if [[ -n "$short_cwd" ]]; then
  out+="${SEP}${C_DIM} ${R}${C_FG}${short_cwd}${R}"
fi

# branch + dirty + ahead/behind
if [[ -n "$branch" ]]; then
  out+="${SEP}${C_BLUE2}${branch}${R}"
  [[ -n "$dirty" ]] && out+="${C_YEL}${dirty}${R}"
  [[ -n "$ahead" ]] && out+=" ${C_DIM}↑${ahead}${R}"
  [[ -n "$behind" ]] && out+=" ${C_DIM}↓${behind}${R}"
fi

# work badge (silent for personal)
[[ -n "$badge" ]] && out+="${SEP}${badge}"

# --- context window usage (the one signal the prompt can't show) ---
if [[ -n "$ctx_pct" && "$ctx_pct" != "null" ]]; then
  pct=$(printf '%.0f' "$ctx_pct" 2>/dev/null || echo 0)
  cc="$C_FG"
  (( pct >= 70 )) && cc="$C_YEL"
  (( pct >= 90 )) && cc="$C_BRED"
  # show 1M models distinctly via size label
  lbl="ctx"
  [[ "$ctx_size" =~ ^[0-9]+$ && "$ctx_size" -ge 1000000 ]] && lbl="ctx·1M"
  out+="${SEP}${C_DIM} ${lbl} ${R}${cc}${pct}%${R}"
fi

# --- session cost ---
if awk "BEGIN{exit !(($cost)+0 > 0)}" 2>/dev/null; then
  costc="$C_FG"
  awk "BEGIN{exit !(($cost)+0 >= 5)}"  2>/dev/null && costc="$C_YEL"
  awk "BEGIN{exit !(($cost)+0 >= 20)}" 2>/dev/null && costc="$C_BRED"
  out+="${SEP}${costc}\$$(printf '%.2f' "$cost" 2>/dev/null)${R}"
fi

# --- lines changed this session ---
added=${added%%.*}; removed=${removed%%.*}
[[ "$added" =~ ^[0-9]+$ ]] || added=0
[[ "$removed" =~ ^[0-9]+$ ]] || removed=0
if (( added > 0 || removed > 0 )); then
  out+="${SEP}"
  (( added > 0 ))   && out+="${C_GRN}+${added}${R}"
  (( added > 0 && removed > 0 )) && out+=" "
  (( removed > 0 )) && out+="${C_RED}-${removed}${R}"
fi

# --- work daily spend: local ledger + "day $X/$Y" segment ---
# A session bills the work API iff ANTHROPIC_API_KEY is present — cc-auth work
# stamps it into the repo's .claude/settings.local.json env block and Claude
# Code injects that block into the process env, which this subprocess inherits.
# Fallback (env injection unavailable): check key PRESENCE in that file via jq.
# The key's value is never stored or used here — presence only.
# Ledger: one file per session per local day, cumulative session cost,
# monotonic writes -> concurrent sessions never race. cc-work-limit (the
# enforcement hook) reads the same ledger and prunes old days.
is_work_billed=0
day_budget="${WORK_DAILY_BUDGET:-}"
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  is_work_billed=1
elif [[ -n "$cwd" && -d "$cwd" ]]; then
  top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  slj="$top/.claude/settings.local.json"
  if [[ -n "$top" && -f "$slj" ]] \
     && jq -e '.env.ANTHROPIC_API_KEY != null' "$slj" >/dev/null 2>&1; then
    is_work_billed=1
    [[ -z "$day_budget" ]] && day_budget=$(jq -r '.env.WORK_DAILY_BUDGET // empty' "$slj" 2>/dev/null)
  fi
fi

if (( is_work_billed )); then
  # default 100 protects work repos stamped before WORK_DAILY_BUDGET existed
  [[ "$day_budget" =~ ^[0-9]+(\.[0-9]+)?$ ]] || day_budget=100
  day_dir="$HOME/.claude/cache/work-day/$(date +%F)"
  sid=$(get '.session_id // empty'); sid=${sid//[^a-zA-Z0-9._-]/}
  if [[ -n "$sid" ]] && awk "BEGIN{exit !(($cost)+0 > 0)}" 2>/dev/null; then
    mkdir -p "$day_dir" 2>/dev/null
    prev=$(cat "$day_dir/$sid" 2>/dev/null)
    [[ "$prev" =~ ^[0-9]+(\.[0-9]+)?$ ]] || prev=0
    if awk -v c="$cost" -v p="$prev" 'BEGIN{exit !(c+0>p+0)}' 2>/dev/null; then
      printf '%s\n' "$cost" > "$day_dir/$sid" 2>/dev/null
    fi
  fi
  day_total=0
  if [[ -d "$day_dir" ]]; then
    # awk over the files directly (not cat|): each file EOF ends its record,
    # so a legacy value written without a trailing newline can't merge digits
    # with the next file
    day_total=$(awk '{s+=$1} END{printf "%.2f", s+0}' "$day_dir"/* 2>/dev/null)
    [[ "$day_total" =~ ^[0-9]+(\.[0-9]+)?$ ]] || day_total=0
  fi
  if awk -v b="$day_budget" 'BEGIN{exit !(b+0>0)}' 2>/dev/null; then
    dc="$C_FG"   # thresholds match the cc-work-limit hook: warn 80%, block 100%
    awk -v t="$day_total" -v b="$day_budget" 'BEGIN{exit !(t>=0.8*b)}' 2>/dev/null && dc="$C_YEL"
    awk -v t="$day_total" -v b="$day_budget" 'BEGIN{exit !(t>=b)}'     2>/dev/null && dc="$C_BRED"
    out+="${SEP}${C_DIM}day ${R}${dc}\$${day_total}${R}${C_DIM}/\$${day_budget%%.*}${R}"
  else
    # budget 0 = enforcement disabled; still show today's figure
    out+="${SEP}${C_DIM}day ${R}${C_FG}\$${day_total}${R}"
  fi
fi

# --- org API spend (work account only; month-to-date vs budget + today) ---
# This NEVER reads the Admin key — only a non-secret JSON cache written by
# ~/.scripts/cc-credits-refresh, which is spawned in the background when stale.
# Active account: explicit override file, else by repo (work badge => work).
acct_state=$(cat "$HOME/.claude/statusline-account" 2>/dev/null)
case "${acct_state:-auto}" in
  work)     active_acct="work" ;;
  personal) active_acct="personal" ;;
  *)        [[ -n "$badge" ]] && active_acct="work" || active_acct="personal" ;;
esac
# Only the work (org) account has a Cost API; personal is individual -> skip.
if [[ "$active_acct" == "work" ]]; then
  cred_cache="$HOME/.claude/cache/credits-work.json"
  refresher="$HOME/.scripts/cc-credits-refresh"
  # spawn a detached background refresh if the cache is missing or > 10 min old
  cred_fa=0
  if [[ -f "$cred_cache" ]]; then
    cred_fa=$(jq -r '.fetched_at // 0' "$cred_cache" 2>/dev/null); cred_fa=${cred_fa%.*}
    [[ "$cred_fa" =~ ^[0-9]+$ ]] || cred_fa=0
  fi
  if (( $(date +%s) - cred_fa > 600 )) && [[ -x "$refresher" ]]; then
    # detached + SIGHUP-immune so the fetch outlives this fast statusline run
    ( nohup "$refresher" work >/dev/null 2>&1 & ) </dev/null >/dev/null 2>&1
  fi
  if [[ -f "$cred_cache" ]]; then
    cred_st=$(jq -r '.status // "none"' "$cred_cache" 2>/dev/null)
    case "$cred_st" in
      ok)
        cred_pct=$(jq -r '.pct // 0'    "$cred_cache" 2>/dev/null); cred_pct=${cred_pct%.*}
        cred_spent=$(jq -r '.spent // 0' "$cred_cache" 2>/dev/null); cred_spent=${cred_spent%.*}
        cred_budget=$(jq -r '.budget // 0' "$cred_cache" 2>/dev/null); cred_budget=${cred_budget%.*}
        cred_today=$(jq -r '.spent_today // 0' "$cred_cache" 2>/dev/null); cred_today=${cred_today%.*}
        [[ "$cred_pct" =~ ^[0-9]+$ ]] || cred_pct=0
        ac="$C_FG"; (( cred_pct >= 70 )) && ac="$C_YEL"; (( cred_pct >= 90 )) && ac="$C_BRED"
        out+="${SEP}${C_DIM}acct ${R}${ac}${cred_pct}%${R}${C_DIM} \$${cred_spent}/\$${cred_budget}${R}"
        out+="${C_DIM} · today \$${cred_today}${R}"
        ;;
      no_key) out+="${SEP}${C_DIM}acct ⚠${R}" ;;   # set an Admin key in statusline-credits.env
      error)  out+="${SEP}${C_DIM}acct ✗${R}" ;;
      *)      out+="${SEP}${C_DIM}acct …${R}" ;;    # fetching
    esac
  else
    out+="${SEP}${C_DIM}acct …${R}"
  fi
fi

printf '%b\n' "$out"
