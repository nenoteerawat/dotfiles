# Global OpenCode rules

These apply to every session. They exist because the local Ollama models run on a
48 GB Mac where context is RAM: one oversized tool result can push the runner into
swap and stall generation for minutes.

## Keep tool output small

- Never let a command print unbounded output. Cap it: `... 2>&1 | tail -20` for
  status/progress, `... | head -c 4000` for files, indexes and API responses.
- Do not run blocking waiters that stream progress into the transcript
  (`kubectl wait`, `helm --wait`, `docker compose up` without `-d`, `tail -f`).
  Run them with output suppressed and check the result afterwards:
  `kubectl wait ... >/dev/null 2>&1; echo exit=$?` then `kubectl get pods -n <ns>`.
- Prefer targeted queries over dumps: `kubectl get pods -o name`, `--no-headers`,
  `grep`/`jq` filters, `wc -l`. Never `cat` a YAML/JSON index or a lock file.
- `head -N` does not bound size when lines are long (Helm `index.yaml`, minified
  JSON, logs). Use `head -c` for anything you have not seen before.
- Read files in ranges (offset/limit) rather than whole files over ~300 lines.

## Web fetches

- `webfetch` returns the whole page. On a local model, fetch a page only when a
  `grep`-able local source (`--help`, `helm show values`, `kubectl explain`) will
  not answer, and ask yourself one question per fetch.

## Session hygiene

- Start a new session per task instead of continuing a long one.
- If the context has grown past ~25K tokens on a local model, run `/compact`
  before the next large step.
- For Kubernetes/Docker-heavy work the Docker VM competes with the model for RAM;
  prefer a `:cloud` model for those sessions.
