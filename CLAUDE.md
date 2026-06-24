# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal dotfiles for macOS, forked from [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public). The repo is checked out into `~/.ghq/github.com/nenoteerawat/dotfiles`; top-level files are intended to live at `$HOME` and `.config/*` at `$XDG_CONFIG_HOME` (`~/.config`). There is **no build step** — once a config is symlinked, editing it here edits the live config. A file only affects the live config once it is actually symlinked into place, so don't assume an edit is live: verify the target is a symlink back into the repo (e.g. `readlink ~/.zshrc`).

Bootstrap is handled by `./install.sh` — an idempotent installer that installs every referenced tool via Homebrew/ghq/npm/mise, clones fzf-tab + TPM, and sets up **zsh** (it intentionally skips the fish config). Run `./install.sh --help` for tiers/flags. It is **Apple-Silicon-only** (the config hardcodes `/opt/homebrew`).

Linking is **per authored file**, not per directory: the installer enumerates `git ls-files` and symlinks each tracked file to its mirror under `$HOME`, keeping `~/.config/*` as **real directories**. This is deliberate — tool-generated files (`lazy-lock.json`, `lazyvim.json`, `~/.config/tmux/plugins/`, Mason, lazygit `state.yml`) then live in the real config dirs and never pollute the repo. Adding a new tracked config file means re-running `./install.sh` to link it.

## Common Commands

### Applying changes

- **Zsh** (`.zshrc`) — `source ~/.zshrc` or open a new shell.
- **tmux** (`.config/tmux/tmux.conf`) — inside tmux: `prefix + r` (prefix is `Ctrl+t`). First-time plugin install: `prefix + I` (TPM).
- **Neovim** (`.config/nvim/`) — restart `nvim`. Plugins are managed by LazyVim: `:Lazy sync`, `:Lazy update`, `:Mason` for LSP/tools.
- **Fish** (`.config/fish/`) — open a new fish shell; `exec fish` to reload in place.
- **macOS defaults** — `./.macos` (re-applies all system tweaks; logout/restart may be needed for some).
- **TouchID for sudo** — `./update_sudo_tid.sh`.

### Commits

Use conventional commits via cz-git (configured in `.czrc` → uses `cz-git` adapter):

- `git cz` — interactive commit (Commitizen).
- In lazygit: press `C` on the files view to launch the same flow (`.config/lazygit/config.yml`).
- Manual commits should follow `<type>(<scope>): <description>` (types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`).
- **Prerequisites:** `git cz` / lazygit `C` need `commitizen` + `cz-git` installed globally (npm). Several `.gitconfig` git aliases (`git a`, `git df`, `git find`) shell out to `peco`, and `git open` needs `hub` — they fail silently if those binaries are absent.

### CI (GitHub Actions)

`.github/workflows/` runs two `anthropics/claude-code-action@beta` workflows (both auth via the `CLAUDE_CODE_OAUTH_TOKEN` secret): `claude.yml` responds to `@claude` mentions in issue/PR comments, and `claude-code-review.yml` auto-reviews every opened/synchronized PR.

### Syncing with upstream

Upstream is `craftzdog/dotfiles-public`. The README's "Syncing with upstream" section is the source of truth. **Note:** the `craftzdog` remote is not configured by default — currently the only remote is `origin`, and upstream content is mirrored as the `origin/craftzdog` branch. So either add the remote first (one-time) or sync from `origin/craftzdog`:

```bash
git remote add craftzdog https://github.com/craftzdog/dotfiles-public.git   # one-time, if missing
git fetch craftzdog
git log master..craftzdog/master --oneline   # review (or master..origin/craftzdog if not added)
git merge craftzdog/master --no-commit       # merge with chance to cherry-pick
git diff --staged                            # discard upstream changes you don't want
git commit -m "feat: sync with upstream craftzdog/dotfiles-public"
```

Keep personal customizations (custom `.zshrc` functions, `.gitconfig` aliases, ghq sparo helpers) isolated so upstream merges of Neovim/tmux configs stay clean.

## Architecture & Layout

### Top-level files map directly into `$HOME`

- `.zshrc` — primary shell config. Sources `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `zsh-history-substring-search` from Homebrew (`$(brew --prefix)/share/...`); loads fzf keybindings via `source <(fzf --zsh)`; and registers many `source <(<tool> completion zsh)` lines. `NODE_EXTRA_CA_CERTS` points at `~/.ssh/gateway-ca-cloudflare.pem` (the Cloudflare gateway cert — migrated from the old Zscaler cert). Order matters: `compinit` (and `bashcompinit`) run **once, early** — right after the `fpath` entries (brew `site-functions` + Docker completions) are set, but **before** the `source <(<tool> completion zsh)` lines — so `compdef` is defined before any completion registers itself. Each tool-completion line is guarded with `command -v <tool>` so an uninstalled tool is skipped, not an error. Note `fzf-tab` is **not** a Homebrew tool — it is sourced from a local ghq clone (`~/.ghq/github.com/Aloxaf/fzf-tab/...`) near the very end, after `starship init` (which is correct: fzf-tab must load after `compinit`).
- `.gitconfig` — includes `[url ...] insteadOf` rewrites that route the work GitHub orgs (`pttep-pcl`, `pttep-fusionsol`) to the **work-account SSH host alias** `github.com-pttep` (which maps to `~/.ssh/pttep_gh_id` via `.ssh/config`). For each org **three** URL spellings are rewritten — `https://github.com/<org>/`, the scp-style `git@github.com:<org>/`, and `ssh://git@github.com/<org>/` — so `git clone` *and* `ghq get` work with any form. The `ssh://` form matters specifically because **ghq normalizes scp-style URLs into `ssh://` before cloning**; without it `ghq get git@github.com:pttep-pcl/…` would fall through to the default `github.com` host (the personal key) and fail with a misleading "Repository not found". Because ghq derives the local path from the *original* URL (before these rewrites), repos still land at the clean `~/.ghq/github.com/<org>/<repo>`. Keep this in mind when debugging clone behavior.
- `.ssh/config` — the **only** file tracked under `.ssh/` (`.gitignore` has `.ssh/*` + `!.ssh/config`, so private keys/`known_hosts`/certs are never committed). Defines two GitHub identities: `Host github.com` → `personal_gh_id` (default, personal account) and `Host github.com-pttep` → `pttep_gh_id` (work account, for the pttep orgs). Both use `IdentitiesOnly yes`. SSH can't pick a key by repo path, so org→key routing is done in `.gitconfig` (above), not here. Linked into `~/.ssh/config` by `install.sh`.
- `.macos` — large script of `defaults write` commands for system preferences (Asia/Bangkok timezone, Dock, Finder, Safari, etc.). The Spotlight section pins the **"Show Spotlight search"** hotkey (`symbolichotkeys` id 64) to `⌘ Space` so Spotlight keeps the default — **Alfred is meant to live on `⌥ Space`, which must be set manually in Alfred Settings → General → Hotkey** (Alfred's hotkey lives in its own preference bundle and can't be scripted via `defaults`).
- `update_sudo_tid.sh` — idempotent (early-exits if `pam_tid.so` is already in `sudo_local`). Rewrites `/etc/pam.d/sudo_local` in one `tee`, but first **backs up** any existing file to `sudo_local.bak` (no longer a blind clobber). The `pam_reattach` line (needed for TouchID inside tmux/screen) is only written when `/opt/homebrew/lib/pam/pam_reattach.so` actually exists — referencing a missing PAM module would break `sudo` entirely with "unable to initialize PAM"; `pam_tid.so` always ships with macOS. After writing it runs a safety-net `sudo -n true` and aborts with restore instructions if PAM no longer initializes. Still hardcodes the **Apple-Silicon** Homebrew path (Intel would need `/usr/local`).

### `.config/` mirrors `$XDG_CONFIG_HOME`

- `.config/nvim/` — LazyVim-based config.
  - `init.lua` → `lua/config/lazy.lua` is the LazyVim bootstrap. Plugin **extras** are listed there (TS, JSON, Go, Rust, Docker, YAML, Helm, Tailwind, SQL, ESLint, Prettier, mini-hipatterns, GitHub). Personal plugin specs live in `lua/plugins/` (`coding.lua`, `colorscheme.lua`, `editor.lua`, `lsp.lua`, `treesitter.lua`, `ui.lua`) and are auto-imported by `{ import = "plugins" }`. Colorscheme (`tokyonight`, style `night`) is selected via the LazyVim opts in `lazy.lua` *and* specced in `plugins/colorscheme.lua` — keep the two in agreement. The spec remaps tokyonight to the macOS 26 Terminal **"Clear Dark"** palette via `on_colors` (so nvim matches Terminal.app + the tmux theme) and keeps `transparent = true` to inherit the terminal's translucent background. Note tokyonight snapshots derived roles (`error`/`warning`/`hint`/`git`/`diff`/`border_highlight`/`rainbow`/`terminal`) *before* `on_colors` runs, so those are re-set inside `on_colors` — don't drop them.
  - `lua/craftzdog/` holds three inherited, live utilities required from `lua/config/keymaps.lua`: `discipline.lua` (rate-limits `hjkl` spam), `hsl.lua` (`<leader>r` hex→HSL), `lsp.lua` (inlay-hints / autoformat toggles). The sibling `plugins.lua` is **dead packer cruft** left over from upstream — never imported (this repo uses lazy.nvim) and safe to delete.
  - `dev = { path = "~/.ghq/github.com" }` in `lazy.lua` lets local clones under ghq override remote plugin sources — useful when hacking on a plugin locally.
  - Claude Code integration is provided by `coder/claudecode.nvim` in `plugins/coding.lua` under `<leader>a*` keymaps.
- `.config/tmux/` — split across `tmux.conf` (entrypoint), `theme.conf`, `statusline.conf`, `utility.conf` (lazygit popup on `prefix+g`, Claude Code popup on `prefix+y` that re-attaches a per-directory `claude-<hash>` session — relies on `md5sum`), and `macos.conf` (loaded only on Darwin). Prefix is `Ctrl+t`. Plugins via TPM (`~/.config/tmux/plugins/tpm`): `tmux-pain-control` + `craftzdog/tmux-claude-session-manager` — **all pane navigation/resize/split bindings (`hjkl`, `HJKL`, `|`, `-`) come from pain-control, not the conf** (the local versions are commented out). After adding a plugin, install it with `prefix + I`. The status bar (`theme.conf`/`statusline.conf`) is themed to the macOS Terminal **"Clear Dark"** palette with `bg=default` to inherit the terminal's translucency (matching the nvim tokyonight remap). Gotcha: `statusline.conf` is sourced after `theme.conf` and overrides its status-bar styling, so editing status colors in `theme.conf` has no visible effect.
- `.config/fish/` — `config.fish` dispatches to `config-osx.fish` / `config-linux.fish` / `config-windows.fish` (empty) based on `uname`, then optionally sources `config-local.fish` if present (machine-specific, untracked overrides). `functions/fzf_change_directory.fish` is the fish twin of the zsh `fzf_change_directory` widget — keep their search roots in sync. Fish uses **starship** (`config.fish` runs `starship init fish`); the old `conf.d/tide.fish` Tide config was removed. Note `install.sh` does **not** set up fish — it's a zsh-only bootstrap — so the fish tree is now effectively unmaintained relative to the primary zsh config.
- `.config/lazygit/config.yml` — adds a `C` custom command that runs `git cz c` (needs cz-git installed globally), and binds `openDiffTool` to `<c-e>`.
- `.config/mise/config.toml` (pins bun/ghq/node/python/ruby/rust to `latest` — note **ghq is managed by mise here**, not only Homebrew) and `.config/ghostty/config` are single-file tool configs. `.config/powershell/` is the Windows shell+prompt setup — two files: `user_profile.ps1` (posh-git, PSReadLine, PSFzf, Terminal-Icons, aliases) driven by the `takuya.omp.json` oh-my-posh theme.

### `.scripts/`

- `ide` — run inside an existing tmux window to create a 5-pane IDE layout (left editor pane + right column split). Not on `$PATH` by default; invoke with `~/.scripts/ide`.
- `cc-acct [work|personal|auto|status]` — picks which account the statusline shows API spend for (`auto` = by repo: pttep → work, else personal). Writes one word to `~/.claude/statusline-account`.
- `cc-credits-refresh [work]` — fetches month-to-date org API spend from the Anthropic Cost API and writes the non-secret cache `~/.claude/cache/credits-<acct>.json`. **The only file that reads the Admin key** (see the status line section). The statusline spawns it in the background when the cache is stale; can also be run on a cron/launchd timer.

### Claude Code status line (`.claude/statusline.sh`)

- `.claude/statusline.sh` — the Claude Code status line ("Beacon"). It's one of **two** tracked files under `.claude/` (with `settings.json`): `.gitignore` ignores all local Claude state with `.claude/*` and re-includes just those two (`!.claude/statusline.sh`, `!.claude/settings.json`) — same idiom as the `.ssh/*` + `!.ssh/config` block. `install.sh` links both via `HOME_FILES` → `~/.claude/statusline.sh` and `~/.claude/settings.json`.
- **Activation lives in `~/.claude/settings.json`, which is now tracked + symlinked.** The status line only renders when `settings.json` has a `statusLine` block (`{"type":"command","command":"~/.claude/statusline.sh","padding":0}`). Because `settings.json` is tracked at `.claude/settings.json` and symlinked by `install.sh`, theme/effort/`enabledPlugins`/hooks/statusLine all sync to a fresh machine automatically — no hand-editing. It's portable (hooks use `$HOME`, statusLine uses `~`); put anything machine-local or secret in `~/.claude/settings.local.json`, which stays gitignored. Gotcha: since the live file is a symlink into the repo, changing settings via `/config` edits the repo file directly (it shows up as a git diff). If a Claude Code update ever rewrites it as a real file and breaks the symlink, re-run `install.sh` to re-link.
- **Design:** flat, foreground-only truecolor on the inherited (translucent) background — matches the tmux `bg=default` + nvim `transparent` "Clear Dark" philosophy; **no** background fills or powerline glyphs. Reads the status JSON on stdin via `jq` (hard dependency; degrades to a plain `Claude` if absent). Deliberately shows only what starship/tmux **don't**: model name (the one bright-blue accent), ghq-shortened `<org>/<repo>` cwd, branch + dirty `*` + ahead/behind, a yellow **work** badge for pttep repos (remote `github.com-pttep`/`pttep-pcl`/`pttep-fusionsol` or the org path segment), live context-window `%` (escalates yellow≥70→red≥90), session `$cost`, and lines `+/-`.
- **Performance gotcha:** Claude Code runs this on every render (debounced 300ms, in-flight runs cancelled), so it uses git **plumbing only** (`rev-parse`, one `rev-list` for ahead/behind, `--no-optional-locks status --porcelain`) and never the network. Keep it fast if you extend it. Test with `echo '{...}' | ~/.claude/statusline.sh`.
- **Org API spend segment (`acct …`).** For the work account it also shows month-to-date Anthropic API spend vs a budget (`acct 62% $312/$500`, escalating yellow≥70→red≥90). Critical facts: (1) this needs an **Admin API key** (`sk-ant-admin01-…`) — the Cost API (`/v1/organizations/cost_report`) rejects a regular `sk-ant-api…` key, and is unavailable on individual (non-org) accounts; (2) there is **no API for prepaid credit *balance*** — only spend, so the budget number is yours (set `WORK_MONTHLY_BUDGET`); (3) the statusline **never reads the key** — it only reads the non-secret cache written by `~/.scripts/cc-credits-refresh`, which sources the key from `~/.claude/statusline-credits.env` (chmod 600, **never committed**, lives in `$HOME` not the repo) and passes it to curl via a stdin config (`-K -`) so it never appears in `ps`/argv. States: `acct 62% $…` (ok) · `acct ⚠` (no/invalid Admin key) · `acct ✗` (API error) · `acct …` (fetching). The segment is shown only when the active account is **work** (personal is individual → no Cost API). Cost data lags ~5 min and the endpoint allows ~1 poll/min, so the cache TTL is 10 min and refreshes happen in a detached background process — never inline. `install.sh` seeds the cache dir + a 600 credential template on fresh machines.

### Personal `.zshrc` helpers worth preserving

These are not in upstream and should survive merges:

- `cdz <key>` — `cdz git` fuzzy-jumps into a ghq-managed repo; `cdz pttep|desk|load` jumps into `~/pttep`, `~/Desktop`, `~/Downloads`; any other arg is treated as a base path.
- `ghq-sparo <url> [profile]` — wraps `sparo clone` with the right ghq directory layout for partial checkouts.
- `fzf_change_directory` (`Ctrl+F`) — combined fzf picker over `$HOME/.config`, this dotfiles repo, ghq repos, and specific pttep GitLab groups. New search roots should be added here and mirrored in the fish version.
- Aliases declared as **functions** (`g`, `ll`, `lla`, `llt`, `llta`, `cdz`, `vim`, `vi`, `gcl`) — done this way for lazygit compatibility; don't convert them to `alias` without checking lazygit still launches editors correctly.

### Bootstrap order in `.zshrc` (important when adding lines)

1. Homebrew shellenv → PATH for everything else.
2. Plugin sources (autosuggest, syntax-highlight, history-substring).
3. `fzf --zsh` keybindings.
4. NVM.
5. **Completion system:** set `fpath` (brew `site-functions` + `~/.docker/completions`), then `compinit`, then `bashcompinit`. This must come **before** anything that calls `compdef`.
6. Tool completions via `source <(<tool> completion zsh)` — each guarded with `command -v <tool>`; plus the gitlab-ci-local `compdef` block. (These rely on step 5 having defined `compdef`.)
7. mise activate, custom functions, and `bindkey` lines.
8. `starship init zsh` — must stay near the end.
9. `fzf-tab` plugin source (correctly after `compinit`).
10. Terraform/Terragrunt/Vault `complete -C` lines (use the `bashcompinit` from step 5; guarded with `[ -x ... ]`).

When adding a new `source <(tool completion zsh)` line, put it in step 6 (after `compinit`) and guard it — never before step 5, or `compdef` won't exist yet.
