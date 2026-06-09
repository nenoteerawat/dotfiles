# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal dotfiles for macOS, forked from [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public). The repo is checked out into `~/.ghq/github.com/nenoteerawat/dotfiles` and individual files/directories are linked into `$HOME` and `$XDG_CONFIG_HOME` (`~/.config`). Editing files in this repo edits the live configuration — there is no build step.

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

### Syncing with upstream

Upstream is `craftzdog/dotfiles-public`, added as the `craftzdog` remote. The README's "Syncing with upstream" section is the source of truth for the workflow; the short version:

```bash
git fetch craftzdog
git log master..craftzdog/master --oneline   # review
git merge craftzdog/master --no-commit       # merge with chance to cherry-pick
git diff --staged                            # discard upstream changes you don't want
git commit -m "feat: sync with upstream craftzdog/dotfiles-public"
```

Keep personal customizations (custom `.zshrc` functions, `.gitconfig` aliases, ghq sparo helpers) isolated so upstream merges of Neovim/tmux configs stay clean.

## Architecture & Layout

### Top-level files map directly into `$HOME`

- `.zshrc` — primary shell config. Sources Homebrew shell tools (autosuggestions, syntax-highlighting, history-substring-search, fzf, fzf-tab) and registers many `source <(<tool> completion zsh)` lines. Order matters: `compinit` is intentionally run **once** at the bottom after all `fpath` entries (including Docker completions) are set.
- `.gitconfig` — includes a `[url "git@github.com:pttep-pcl/"] insteadOf` rewrite that silently switches HTTPS clones of `pttep-pcl/*` repos to SSH. Keep this in mind when debugging clone behavior.
- `.macos` — large script of `defaults write` commands for system preferences (Asia/Bangkok timezone, Dock, Finder, Safari, etc.).
- `update_sudo_tid.sh` — idempotent; installs `pam_reattach` + `pam_tid` lines into `/etc/pam.d/sudo_local` so TouchID works inside tmux.

### `.config/` mirrors `$XDG_CONFIG_HOME`

- `.config/nvim/` — LazyVim-based config.
  - `init.lua` → `lua/config/lazy.lua` is the LazyVim bootstrap. Plugin **extras** are listed there (TS, Go, Rust, Docker, YAML, Helm, Tailwind, SQL, ESLint, Prettier, GitHub). Personal plugin specs live in `lua/plugins/` (`coding.lua`, `colorscheme.lua`, `editor.lua`, `lsp.lua`, `treesitter.lua`, `ui.lua`) and are auto-imported by `{ import = "plugins" }`.
  - `lua/craftzdog/` holds inherited utilities (`discipline.lua`, `hsl.lua`, `lsp.lua`, `plugins.lua`).
  - `dev = { path = "~/.ghq/github.com" }` in `lazy.lua` lets local clones under ghq override remote plugin sources — useful when hacking on a plugin locally.
  - Claude Code integration is provided by `coder/claudecode.nvim` in `plugins/coding.lua` under `<leader>a*` keymaps.
- `.config/tmux/` — split across `tmux.conf` (entrypoint), `theme.conf`, `statusline.conf`, `utility.conf` (lazygit popup on `prefix+g`, Claude Code popup on `prefix+y` that re-attaches a per-directory `claude-<hash>` session), and `macos.conf` (loaded only on Darwin). Prefix is `Ctrl+t`. Plugins use TPM at `~/.config/tmux/plugins/tpm`.
- `.config/fish/` — `config.fish` dispatches to `config-osx.fish` / `config-linux.fish` / `config-windows.fish` based on `uname`, then optionally sources `config-local.fish` if present (use this for machine-specific, untracked overrides). `functions/fzf_change_directory.fish` is the fish twin of the zsh `fzf_change_directory` widget — keep them in sync when adding new search roots.
- `.config/lazygit/config.yml` — adds a `C` custom command that runs `git cz c`; depends on cz-git being installed globally.
- `.config/mise/config.toml`, `.config/ghostty/config`, `.config/powershell/` — single-file tool configs.

### `.scripts/`

- `ide` — run inside an existing tmux window to create a 5-pane IDE layout (left editor pane + right column split). Not on `$PATH` by default; invoke with `~/.scripts/ide`.

### Personal `.zshrc` helpers worth preserving

These are not in upstream and should survive merges:

- `cdz <key>` — `cdz git` fuzzy-jumps into a ghq-managed repo; `cdz pttep|desk|load` jumps into `~/pttep`, `~/Desktop`, `~/Downloads`; any other arg is treated as a base path.
- `ghq-sparo <url> [profile]` — wraps `sparo clone` with the right ghq directory layout for partial checkouts.
- `fzf_change_directory` (`Ctrl+F`) — combined fzf picker over `$HOME/.config`, this dotfiles repo, ghq repos, and specific pttep GitLab groups. New search roots should be added here and mirrored in the fish version.
- Aliases declared as **functions** (`g`, `ll`, `lla`, `llt`, `llta`, `vim`, `vi`, `gcl`) — done this way for lazygit compatibility; don't convert them to `alias` without checking lazygit still launches editors correctly.

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
