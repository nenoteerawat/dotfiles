# Claude context windows — the verified facts

Researched 2026-08-05, adversarially verified 2026-08-06 against live Anthropic documentation (`platform.claude.com`, `code.claude.com`) and downloaded Claude 5-family system-card PDFs. **This is a snapshot, not a living spec** — Anthropic's docs change, and every number on this page can go stale. Every claim below was independently re-fetched and checked against its primary source in a dedicated adversarial verification pass, separate from the original research: **13 of 13 confirmed, zero refuted, zero unverified.**

The full research trail and verification report lived only in this repo's gitignored `.dot-agent-deck/` directory — this page distills the verified, tracked subset of those findings so they survive a fresh clone.

## Per-model summary

| Model | Advertised context window | Claude Code auto-compact | Published degradation threshold |
|---|---|---|---|
| Claude Fable 5 | 1M tokens (default = max) | Near the full ~1M ceiling — no documented early cutoff | **None published** |
| Claude Opus 5 | 1M tokens (default = max) | Near the full ~1M ceiling by default; **200K** on a 200K deployment (Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry) | **None published** |
| Claude Sonnet 5 | 1M tokens (default = max, no 200K variant) | **~967K tokens** — an Anthropic-tuned early cutoff unique to this model | **None published** |
| Claude Haiku 4.5 | 200K tokens (fixed — no 1M option exists) | Compacts near its context limit (general rule); its only ceiling is 200K, so there's no smaller early cutoff to document | **None published** |

All four rows read "None published" deliberately, not because the research came up short — see below.

## The crux finding

**No source — official or third-party — publishes a numeric effective-context or quality-degradation threshold for Fable 5, Opus 5, Sonnet 5, or Haiku 4.5.** This is a well-hunted absence, not a gap in how hard anyone looked:

- Anthropic's own **Haiku 4.5 system card** has no long-context, GraphWalks, MRCR, retrieval, or recall section at all — it's a pure safety card (bias, prompt injection, alignment audits, CBRN/autonomy/cyber evals). Grepping the full extracted PDF text for "recall," "retrieval," and "degrad" returns zero hits.
- Chroma's well-known third-party "Context Rot" study (`trychroma.com/research/context-rot`, published 2025-07-14) tests 18 models — none of them from the Claude 5 family. It predates Fable 5/Opus 5/Sonnet 5/Haiku 4.5 by months.
- RULER (NVIDIA, [arXiv:2404.06654](https://arxiv.org/abs/2404.06654)) and NoLiMa (Adobe/UMD, [arXiv:2502.05167](https://arxiv.org/abs/2502.05167)), the two most-cited third-party long-context benchmarks, both predate the Claude 5 family entirely and test neither it nor anything close to it.
- Fiction.liveBench's leaderboard is JS-rendered and inaccessible to fetch tooling; no current score for any of these four models could be retrieved.

A commonly-asked version of this question is whether Fable 5 needs to stay under roughly 250K tokens for best results. **That specific figure is unaddressed, not refuted** — no source tested it, so there's nothing to either confirm or contradict. Circumstantial signals lean mildly against treating it as a real cliff (Fable 5's own Claude Code default lets it run to roughly 4x that point before compacting, and the one closely-related official benchmark below shows only gradual degradation out to the full 1M) — but "unaddressed" is the accurate word here, not "debunked."

### A genuine, unresolved tension in Anthropic's own docs

Two official statements sit next to each other without ever being reconciled:

> "As token count grows, accuracy and recall degrade, a phenomenon known as *context rot*." — [Context windows](https://platform.claude.com/docs/en/build-with-claude/context-windows)

> "Long-context work, with a 1M token context window as both the default and the maximum, and consistent instruction following, tool calling, and reasoning **throughout the window**." — [What's new in Claude Opus 5](https://platform.claude.com/docs/en/about-claude/models/whats-new-opus-5)

Neither statement carries a number. The first is a general, model-agnostic claim; the second is Opus 5's own release notes asserting the opposite framing for that specific model. Both are reported here rather than resolved in either direction.

## Numbers that look real but aren't

Two figures keep surfacing in searches and both fail on inspection. Naming them here so nobody re-finds and trusts them:

**"Degradation starting around 400K tokens, ~2% effectiveness loss per 100K."** Routinely attributed to Fable 5 or "Claude's 1M window" generally. The actual source (`verdent.ai/guides/claude-code-1m-context-window`, a commercial coding-tool's marketing/guides blog) says:

> "Verdent's roundup of independent testing found degradation starting around 400K tokens and retrieval becoming unreliable past 600K on **Sonnet 4.6**, with a working heuristic of about 2% effectiveness loss per 100K tokens."

It's about Sonnet 4.6 — not a Claude 5-family model, and not Fable 5 — attributed to unnamed "independent testing" with no dataset, methodology, or link.

**"Fable 5 effective reasoning context (our tests): ~600,000 tokens."** Source: `contracollective.com`. The entire methodology, quoted in full: *"We tested 10 distinct facts scattered through a 500k token context and asked questions that required combining at least 3 of them."* One non-reproducible 10-fact test, no trial count, no dataset, no code — published by a firm whose own site advertises "Custom Shopify Themes" alongside "Contra Collective ships production AI integrations for enterprise teams." Not a benchmark lab by any reasonable standard. (For what it's worth, even this uncredentialed number sits well above 250K, not near it.)

### Checked and rejected as unverified

These surfaced during research and were deliberately not used, because none traces to a primary source. Listed so nobody re-treads this ground:

- **Opus 4.6 MRCR v2 8-needle score** — secondary sources disagree (76% vs. 78.3%) and neither traces cleanly to the Opus 4.6 system card. Out of scope regardless: Opus 4.6 predates the Claude 5 family.
- **"RULER puts Haiku 4.5 at unreliable past ~130K"** — could not be traced to the actual RULER paper, whose 2024 test set doesn't include Haiku 4.5 or any Claude 5-family model. Reads as a search-engine conflation of RULER's general finding with a specific current model, not a real re-benchmark.
- **Fiction.liveBench scores for any Claude 5-family model** — leaderboard is JS-rendered and inaccessible to fetch tooling; a mirror returned HTTP 403.

## GraphWalks: the one official degradation curve — and it isn't Fable 5's

The only quantified, official long-context degradation table for any Claude 5-family model lives in the **Fable 5 & Mythos 5 system card, §8.13**. It measures **Mythos 5** — Fable 5's limited-availability sibling. **There is no Fable 5 row or column anywhere in that table.** Do not read these as Fable 5's numbers.

| Evaluation (F1 score) | Mythos 5 | Mythos Preview | Opus 4.8 | GPT-5.5 |
|---|---|---|---|---|
| GraphWalks BFS, 256K subset | 91.1 | 85.7 | 85.9 | 73.7 |
| GraphWalks BFS, 1M subset | 79.4 | 74.3 | 68.1 | 45.4 |
| GraphWalks Parents, 256K subset | 99.96 | 99.9 | 99.3 | 90.1 |
| GraphWalks Parents, 1M subset | 97.5 | 95.5 | 83.3 | 58.5 |

GraphWalks is a multi-hop long-context reasoning benchmark: the context window is filled with a directed graph of hexadecimal-hash nodes, and the model performs a breadth-first search (BFS) or identifies parent nodes from a random starting node. Scores are averaged over 5 trials. Anthropic's own caveat, kept intact:

> "1M context subset results are not reproducible via the public API, as the problems exceed its 1M token limit."

This specific number was produced with internal tooling, not something a customer can reproduce against the shipped API.

**Derived, not Anthropic's own framing** — applying the third-party NoLiMa benchmark's "≥85%-of-base-score retained" convention to these official numbers, as a lens only: Mythos 5 retains 87.2% of its 256K BFS score at 1M (79.4/91.1); Opus 4.8 retains 79.3% (68.1/85.9) — i.e. on this eval, Mythos 5 degrades *less* than Opus 4.8 does, not more. On the easier Parents-retrieval task, Mythos 5 stays far above that line (97.5%); Opus 4.8 sits just under it (83.9%).

**The other official long-context data point — ProgramBench — shows no visible decline, but isn't a clean isolate.** Opus 5's and Sonnet 5's own system cards report an agentic-coding benchmark (5 sequential episodes, each with "a fresh context budget of up to 1M tokens," continuing from the previous episode's codebase). Scores *rise* across episodes: Opus 5 83%→93%, Sonnet 5 76–86% (vs. 52–74% for Sonnet 4.6), Mythos 5 84%→93%, Opus 4.8 80%→90%. Neither the Opus 5 nor the Sonnet 5 system card contains a GraphWalks, MRCR, or needle-in-a-haystack section — ProgramBench is their only long-context eval. Caveat: later episodes both grow the context *and* add genuinely useful accumulated work, so rising scores aren't proof raw retrieval accuracy stays flat — only evidence that real agentic coding tasks don't visibly degrade out to 1M in Anthropic's own testing.

## Compaction defaults — two different systems, easy to conflate

Claude Code (the product) and the raw Messages API (the `context_management` beta) compact independently, with different defaults:

| System | Default trigger | Notes |
|---|---|---|
| Claude Code — Sonnet 5 | **~967K tokens** | Anthropic-tuned; the only model with an early, model-specific default below its own ceiling |
| Claude Code — Fable 5 / full-1M Opus 5 | Near the full **~1M** ceiling | No documented early cutoff |
| Claude Code — Opus 5 on a 200K deployment (Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry) | **200K** | Fixed boundary; doesn't apply to the default 1M Anthropic-API deployment |
| Claude Code — user override (any model) | **100K – 1M** | `/autocompact <value>`, the `--autocompact` flag, or `CLAUDE_CODE_AUTO_COMPACT_WINDOW` |
| Raw Messages API `context_management` beta | **150K** (minimum 50K) | Server-side; `trigger: {"type": "input_tokens", "value": N}`; same default regardless of model |

The Messages API default (150K) is far more conservative than Claude Code's shipped per-model defaults (967K–~1M) — a developer building directly on the API gets compacted much earlier than a Claude Code user, by default, on the same model.

### Anthropic's own evals compact earlier than their shipped product defaults

All three Claude 5-family system cards state, nearly word for word, for their BrowseComp-style search-agent evals:

> "To extend beyond the 1M-token context window, we used context compaction, triggered at 200k tokens."

The Fable 5/Mythos 5 card's multi-agent-harness eval goes further: *"Subagents have a 200k-token context window without compaction, whereas the orchestrator uses context compaction triggered at 100k tokens."*

None of the three cards say *why* — cost, quality, or latency — 200K/100K was chosen for internal eval harnesses, when the shipped product default lets the same models run to 967K–~1M before compacting. Reported here as a fact worth noticing, not as evidence of a quality cliff at 100K/200K.

None of the above adds up to a rule of thumb, and this page won't invent one. What Anthropic does publish is more modest — concrete and worth following anyway:

## Practical guidance

- **Put long documents at the top of the prompt** — above your query, instructions, and examples. Anthropic states this "improves performance across all models."
- **Put the query last.** Anthropic's own tests found queries at the end "can improve response quality by up to 30 percent... especially with complex, multidocument inputs."
- **Ask Claude to quote relevant passages before answering.** For long-document tasks, this helps it focus on the relevant content and ignore the rest.
- **`/compact` with a focus** before starting a long new task in Claude Code.
- **`/clear` between unrelated tasks** — old conversation crowds out the files you need next and costs tokens on every subsequent message.

## Two premises worth correcting

**1. There is no long-context pricing premium on Claude 4.6-and-later models.** Triple-sourced, verbatim:

> "Claude 4.6 and later models... include the full 1M token context window at standard pricing. (A 900k-token request is billed at the same per-token rate as a 9k-token request.)"

This covers Fable 5, Opus 5, and Sonnet 5. (Haiku 4.5 has no 1M option, so the question doesn't apply to it.) **Fast mode** (Opus 5 / Opus 4.8 only, research preview) is roughly 2x ($10/$50 vs. $5/$25 per MTok in/out) — but it's a flat *speed* premium that "applies across the full context window, including requests over 200k input tokens," not a length-triggered cliff. The older industry-wide "2x beyond 200K" pattern applied to prior-generation 1M-beta models (e.g. Sonnet 4.5's 1M beta) — not to the current Claude 5 family.

**2. Claude 4.7-and-later models use a newer tokenizer that produces "approximately 30% more tokens for the same text."** Anthropic states the boundary as "Claude Sonnet 4.6 and earlier models use the previous tokenizer." **Derived, not Anthropic's own framing** — applying that boundary to the four models on this page: Fable 5, Opus 5, and Sonnet 5 (all newer than Sonnet 4.6) get the newer, more-token-hungry tokenizer; Haiku 4.5 (older than the 4.6 boundary) uses the previous one. Practical effect: on the three Claude 5-family models with the newer tokenizer, the same prompt content consumes more of the window than it would on Sonnet 4.6-and-earlier — any given fill percentage arrives sooner than a naive estimate would predict.

## Context awareness

Claude Sonnet 5, Sonnet 4.6, Sonnet 4.5, and Haiku 4.5 have **context awareness**: the API silently injects `<budget:token_budget>` and post-tool-call `<system_warning>Token usage: X/Y; Z remaining</system_warning>` tags so the model can self-pace as the window fills.

**Claude Opus 4.7 and later Opus models, Fable 5, and Mythos 5 do not receive these injected tags.** They can instead opt into the separate **task budgets** beta: an explicit, advisory ceiling across an entire agentic loop (thinking + tool calls + tool results + output), minimum 20,000 tokens, via the `task-budgets-2026-03-13` header. Task budgets are supported on Opus 5, Fable 5, Mythos 5, Opus 4.8, and Opus 4.7 (beta) — **not** on Sonnet 5, Opus 4.6, Sonnet 4.6, or Haiku 4.5 — and explicitly not supported on Claude Code or Cowork surfaces at all.

## Context window vs. effort — a separate axis

`effort` (`low`/`medium`/`high`/`xhigh`/`max`) controls how much of a turn's output budget Claude spends on thinking versus acting. **It does not resize the context window** — the two are independent axes, and nothing in Anthropic's docs describes effort affecting window size.

One correction worth stating precisely, since it's easy to get wrong: the legacy `budget_tokens` parameter (manual thinking-token cap, minimum 1,024, must be less than `max_tokens`) still works on **Haiku 4.5, Sonnet 4.5, Opus 4.5, Opus 4.6, and Sonnet 4.6** — it is not exclusive to models ≤4.5. Anthropic's own word "deprecated" applies only to the **Opus 4.6 / Sonnet 4.6** pair ("deprecated on the Claude 4.6 models, requests using it still succeed"); for **Haiku 4.5, Sonnet 4.5, and Opus 4.5** manual thinking is simply the only mode available, so there's no adaptive alternative for it to be deprecated in favor of. It's removed entirely (400 error) starting at **Opus 4.7, Sonnet 5, and Fable 5**, which instead use adaptive thinking with `effort` as soft guidance only — no fixed numeric thinking budget exists at any effort level, on any current-generation model.

## Sources

Every quote and number above was independently re-fetched from these primary sources during verification, not taken on trust from the original research pass.

Fetched directly (web pages):
- https://platform.claude.com/docs/en/build-with-claude/context-windows
- https://platform.claude.com/docs/en/build-with-claude/compaction
- https://platform.claude.com/docs/en/about-claude/pricing
- https://platform.claude.com/docs/en/about-claude/models/whats-new-opus-5
- https://platform.claude.com/docs/en/about-claude/models/overview
- https://platform.claude.com/docs/en/build-with-claude/effort
- https://platform.claude.com/docs/en/build-with-claude/thinking-steering-and-cost
- https://platform.claude.com/docs/en/build-with-claude/extended-thinking
- https://platform.claude.com/docs/en/build-with-claude/task-budgets
- https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/long-context-tips
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- https://code.claude.com/docs/en/context-window
- https://code.claude.com/docs/en/model-config
- https://code.claude.com/docs/en/settings
- https://www.trychroma.com/research/context-rot (third-party; confirms absence, tests no Claude 5-family model)

Downloaded and parsed locally (PDFs exceed the web-fetch tool's size limit):
- Claude Opus 5 System Card — https://www-cdn.anthropic.com/b514064af1408018e64b1ad24e7d5e75850b4ffd/Claude%20Opus%205%20System%20Card.pdf
- Claude Sonnet 5 System Card — https://www-cdn.anthropic.com/480e0bb54327b9622282e9c39a83a4f490ed377e/Claude%20Sonnet%205%20System%20Card.pdf
- Claude Fable 5 & Mythos 5 System Card — https://www-cdn.anthropic.com/d00db56fa754a1b115b6dd7cb2e3c342ee809620.pdf
- Claude Haiku 4.5 System Card — https://assets.anthropic.com/m/99128ddd009bdcb/original/Claude-Haiku-4-5-System-Card.pdf (no long-context section found)

Third-party benchmark papers (predate the Claude 5 family; cited only to support the well-hunted-absence finding, not for any number about these models):
- RULER — https://arxiv.org/abs/2404.06654
- NoLiMa — https://arxiv.org/abs/2502.05167

Rejected-on-inspection sources (see "Numbers that look real but aren't" above):
- https://verdent.ai/guides/claude-code-1m-context-window
- https://contracollective.com
