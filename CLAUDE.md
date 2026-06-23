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

- `.zshrc` — primary shell config. Sources `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `zsh-history-substring-search` from Homebrew (`$(brew --prefix)/share/...`); loads fzf keybindings via `source <(fzf --zsh)`; and registers many `source <(<tool> completion zsh)` lines. `NODE_EXTRA_CA_CERTS` points at `~/.ssh/gateway-ca-cloudflare.pem` (the Cloudflare gateway cert — migrated from the old Zscaler cert). Order matters: `compinit` is intentionally run **once** at the bottom after all `fpath` entries (including Docker completions) are set. Note `fzf-tab` is **not** a Homebrew tool — it is sourced from a local ghq clone (`~/.ghq/github.com/Aloxaf/fzf-tab/...`) near the very end, after `starship init`.
- `.gitconfig` — includes a `[url "git@github.com:pttep-pcl/"] insteadOf` rewrite that silently switches HTTPS clones of `pttep-pcl/*` repos to SSH. Keep this in mind when debugging clone behavior.
- `.macos` — large script of `defaults write` commands for system preferences (Asia/Bangkok timezone, Dock, Finder, Safari, etc.).
- `update_sudo_tid.sh` — idempotent (guards on `pam_tid.so` already being present), but it **overwrites** `/etc/pam.d/sudo_local` with `>` (clobbering any existing content) rather than appending, and hardcodes the **Apple-Silicon** Homebrew path `/opt/homebrew/lib/pam/pam_reattach.so` (Intel would need `/usr/local`). Writes `pam_reattach` + `pam_tid` lines so TouchID works inside tmux.

### `.config/` mirrors `$XDG_CONFIG_HOME`

- `.config/nvim/` — LazyVim-based config.
  - `init.lua` → `lua/config/lazy.lua` is the LazyVim bootstrap. Plugin **extras** are listed there (TS, JSON, Go, Rust, Docker, YAML, Helm, Tailwind, SQL, ESLint, Prettier, mini-hipatterns, GitHub). Personal plugin specs live in `lua/plugins/` (`coding.lua`, `colorscheme.lua`, `editor.lua`, `lsp.lua`, `treesitter.lua`, `ui.lua`) and are auto-imported by `{ import = "plugins" }`. Colorscheme (`solarized-osaka`) is selected via the LazyVim opts in `lazy.lua` *and* specced in `plugins/colorscheme.lua` — keep the two in agreement.
  - `lua/craftzdog/` holds three inherited, live utilities required from `lua/config/keymaps.lua`: `discipline.lua` (rate-limits `hjkl` spam), `hsl.lua` (`<leader>r` hex→HSL), `lsp.lua` (inlay-hints / autoformat toggles). The sibling `plugins.lua` is **dead packer cruft** left over from upstream — never imported (this repo uses lazy.nvim) and safe to delete.
  - `dev = { path = "~/.ghq/github.com" }` in `lazy.lua` lets local clones under ghq override remote plugin sources — useful when hacking on a plugin locally.
  - Claude Code integration is provided by `coder/claudecode.nvim` in `plugins/coding.lua` under `<leader>a*` keymaps.
- `.config/tmux/` — split across `tmux.conf` (entrypoint), `theme.conf`, `statusline.conf`, `utility.conf` (lazygit popup on `prefix+g`, Claude Code popup on `prefix+y` that re-attaches a per-directory `claude-<hash>` session — relies on `md5sum`), and `macos.conf` (loaded only on Darwin). Prefix is `Ctrl+t`. Plugins are just TPM (`~/.config/tmux/plugins/tpm`) + `tmux-pain-control` — **all pane navigation/resize/split bindings (`hjkl`, `HJKL`, `|`, `-`) come from pain-control, not the conf** (the local versions are commented out). Gotcha: `statusline.conf` is sourced after `theme.conf` and overrides its status-bar styling, so editing status colors in `theme.conf` has no visible effect.
- `.config/fish/` — `config.fish` dispatches to `config-osx.fish` / `config-linux.fish` / `config-windows.fish` (empty) based on `uname`, then optionally sources `config-local.fish` if present (machine-specific, untracked overrides). `functions/fzf_change_directory.fish` is the fish twin of the zsh `fzf_change_directory` widget — keep their search roots in sync. Fish uses **starship** (`config.fish` runs `starship init fish`); the old `conf.d/tide.fish` Tide config was removed. Note `install.sh` does **not** set up fish — it's a zsh-only bootstrap — so the fish tree is now effectively unmaintained relative to the primary zsh config.
- `.config/lazygit/config.yml` — adds a `C` custom command that runs `git cz c` (needs cz-git installed globally), and binds `openDiffTool` to `<c-e>`.
- `.config/mise/config.toml` (pins bun/ghq/node/python/ruby/rust to `latest` — note **ghq is managed by mise here**, not only Homebrew) and `.config/ghostty/config` are single-file tool configs. `.config/powershell/` is the Windows shell+prompt setup — two files: `user_profile.ps1` (posh-git, PSReadLine, PSFzf, Terminal-Icons, aliases) driven by the `takuya.omp.json` oh-my-posh theme.

### `.scripts/`

- `ide` — run inside an existing tmux window to create a 5-pane IDE layout (left editor pane + right column split). Not on `$PATH` by default; invoke with `~/.scripts/ide`.

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
4. NVM, mise, tool completions via `source <(... completion zsh)`.
5. Custom functions and `bindkey` lines.
6. `starship init zsh` — must stay near the end.
7. `fzf-tab` plugin source.
8. Terraform/Terragrunt/Vault `complete -C` lines via `bashcompinit`.
9. Final `compinit`. Adding new completions above this line is fine; running `compinit` earlier will break Docker completions and the `bashcompinit`-backed ones.
