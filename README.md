# nenoteerawat's dotfiles

**Warning**: Don't blindly use my settings unless you know what that entails. Use at your own risk!

## Contents

- [Zsh config](#zsh-setup-macos) (primary shell)
- [Fish config](#fish-setup)
- [Neovim config](#neovim-setup)
- [tmux config](#tmux-setup)
- [tmux control](#tmux-control)
- [Git config](#git-config)
- [macOS defaults](#macos-defaults)
- [Scripts](#scripts)
- [Local AI coding implementor](#local-ai-coding-implementor) (Claude designs, local model implements)
- [Claude Code](#claude-code)

## Neovim setup

Neovim configuration based on [LazyVim](https://www.lazyvim.org/) with the [tokyonight](https://github.com/folke/tokyonight.nvim) theme (style `night`, remapped to the macOS Terminal "Clear Dark" palette, transparent).

### Requirements

- Neovim >= **0.9.0** (needs to be built with **LuaJIT**)
- Git >= **2.19.0** (for partial clones support)
- [LazyVim](https://www.lazyvim.org/)
- a [Nerd Font](https://www.nerdfonts.com/) (v3.0 or greater) **_(optional, but needed to display some icons)_**
- [lazygit](https://github.com/jesseduffield/lazygit) **_(optional)_**
- a **C** compiler for `nvim-treesitter`. See [here](https://github.com/nvim-treesitter/nvim-treesitter#requirements)
- for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) **_(optional)_**
  - **live grep**: [ripgrep](https://github.com/BurntSushi/ripgrep)
  - **find files**: [fd](https://github.com/sharkdp/fd)
- A terminal that supports true color and *undercurl*:
  - [kitty](https://github.com/kovidgoyal/kitty) **_(Linux & macOS)_**
  - [wezterm](https://github.com/wez/wezterm) **_(Linux, macOS & Windows)_**
  - [alacritty](https://github.com/alacritty/alacritty) **_(Linux, macOS & Windows)_**
  - [iterm2](https://iterm2.com/) **_(macOS)_**

### Plugins

| Plugin | Description |
|--------|-------------|
| [tokyonight](https://github.com/folke/tokyonight.nvim) | Colorscheme (style `night`, remapped to Terminal "Clear Dark", transparent) |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder with fzf-native and file-browser |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting (Go, Rust, TypeScript, CSS, Fish, SQL, and more) |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Completion engine |
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua) | GitHub Copilot |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Tab/buffer line |
| [incline.nvim](https://github.com/b0o/incline.nvim) | Floating filename indicator |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [noice.nvim](https://github.com/folke/noice.nvim) | UI for messages, cmdline and popupmenu |
| [zen-mode.nvim](https://github.com/folke/zen-mode.nvim) | Distraction-free coding |
| [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) | Color highlighting (hex, rgb, hsl, tailwind) |
| [inc-rename.nvim](https://github.com/smjonas/inc-rename.nvim) | Incremental rename |
| [dial.nvim](https://github.com/monaqa/dial.nvim) | Enhanced increment/decrement |
| [close-buffers.nvim](https://github.com/kazhala/close-buffers.nvim) | Close hidden/nameless buffers |

### LSP Servers (via Mason)

- `typescript-language-server` - TypeScript/JavaScript
- `tailwindcss-language-server` - Tailwind CSS
- `css-lsp` - CSS
- `helm-ls` - Helm charts
- `lua_ls` - Lua
- `yamlls` - YAML
- `html` - HTML

## Zsh setup (macOS)

Primary shell configuration in `.zshrc` using Zsh with [Starship](https://starship.rs/) prompt.

### Zsh Plugins

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like autosuggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Syntax highlighting
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) - History search with arrow keys
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) - FZF-powered tab completion with tmux popup
- [Starship](https://starship.rs/) - Cross-shell prompt

### CLI Tools

- [Homebrew](https://brew.sh/) - Package manager
- [Eza](https://github.com/eza-community/eza) - `ls` replacement (`ll`, `lla`, `llt`, `llta`)
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [fd](https://github.com/sharkdp/fd) - `find` replacement
- [ghq](https://github.com/x-motemen/ghq) - Local Git repository organizer
- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for Git
- [Neovim](https://neovim.io/) - Editor (aliased as `vim` and `vi`)
- [NVM](https://github.com/nvm-sh/nvm) - Node version manager
- [mise](https://mise.jdx.dev/) - Runtime manager
- [sparo](https://tiktok.github.io/sparo/) - Sparse Git checkout

### CLI Completions

Autocompletions are configured for:
- Git Flow, GitHub CLI (`gh`), `gitlab-ci-local`
- Docker, kubectl, Helm, k3d
- Terraform, Terragrunt, Vault
- Google Cloud SDK, Atlas
- Angular CLI, Trivy, Dagger

### Custom Functions & Aliases

| Command | Description |
|---------|-------------|
| `cdz git` | Fuzzy-find and cd into a ghq-managed repo |
| `cdz pttep` / `cdz desk` / `cdz load` | Fuzzy-find directories under specific paths |
| `Ctrl+F` | fzf project directory switcher (ghq repos, gitlab repos, current dir) |
| `ghq-sparo <url> [profile]` | Clone repos with sparo sparse checkout |
| `g` | Alias for `git` |
| `ll` / `lla` | `eza -l -g --icons` (with/without hidden files) |
| `llt` / `llta` | Tree listing with eza (depth 2) |
| `vim` / `vi` | Alias for `nvim` |
| `gcl` | Alias for `gitlab-ci-local` |

## Fish setup

Fish shell configuration with platform-specific configs (macOS/Linux/Windows).

- [Fish shell](https://fishshell.com/)
- [Tide](https://github.com/IlanCosman/tide) - Shell theme
- [Starship](https://starship.rs/) - Prompt
- [Eza](https://github.com/eza-community/eza) - `ls` replacement (macOS)
- [fzf](https://github.com/PatrickF1/fzf.fish) - Interactive filtering
- [Nerd fonts](https://github.com/ryanoasis/nerd-fonts) - Patched fonts

### Fish Key Bindings

| Key | Action |
|-----|--------|
| `Ctrl+F` | fzf project directory switcher |
| `Ctrl+L` | Forward character (vim-like) |
| `Ctrl+D` | Delete character (prevents terminal close) |
| `Ctrl+O` | fzf directory finder |

## tmux setup

tmux configuration with Solarized theme and vi mode.

- Prefix key: `Ctrl+t`
- [TPM](https://github.com/tmux-plugins/tpm) - Plugin manager
- [tmux-pain-control](https://github.com/tmux-plugins/tmux-pain-control) - Pane navigation bindings

### tmux Key Bindings

| Key | Action |
|-----|--------|
| `prefix + r` | Reload tmux config |
| `prefix + o` | Open current directory in Finder |
| `prefix + e` | Kill all panes except current |
| `prefix + g` | Open lazygit in a popup (80% width/height) |
| `Ctrl+Shift+Left/Right` | Move window left/right |

### IDE Layout Script

`.scripts/ide` - Creates a tmux IDE-like layout with split panes.

## tmux control

Complete shortcut reference for controlling tmux. **Prefix is `Ctrl+t`** (rebound from default `Ctrl+b`).

### Core / Session

| Shortcut | Action |
|----------|--------|
| `Ctrl+t` | Prefix key |
| `prefix + r` | Reload `tmux.conf` |
| `prefix + o` | Open current pane's directory in Finder |
| `prefix + e` | Kill all other panes in the current window |
| `prefix + I` | Install plugins (TPM, first-time only) |
| `prefix + d` | Detach from session |
| `prefix + s` | List/switch sessions |

### Popups (custom)

| Shortcut | Action |
|----------|--------|
| `prefix + g` | Open **lazygit** in an 80%×80% popup at the pane's cwd |
| `prefix + y` | Open **Claude Code** in an 80%×80% popup, attached to a per-directory `claude-<hash>` session |

### Windows

| Shortcut | Action |
|----------|--------|
| `prefix + c` | Create new window |
| `prefix + ,` | Rename current window |
| `prefix + n` / `p` | Next / previous window |
| `prefix + 0`–`9` | Jump to window by number |
| `prefix + w` | List windows |
| `prefix + &` | Kill current window |
| `Ctrl+Shift+Left` | Move current window left (swap + previous) |
| `Ctrl+Shift+Right` | Move current window right (swap + next) |

### Panes (via `tmux-pain-control`)

| Shortcut | Action |
|----------|--------|
| `prefix + h` / `j` / `k` / `l` | Select pane left / down / up / right |
| `prefix + H` / `J` / `K` / `L` | Resize pane in that direction |
| `prefix + -` | Split window horizontally (new pane below) |
| `prefix + \|` | Split window vertically (new pane right) |
| `prefix + \\` | Split full-width horizontal |
| `prefix + _` | Split full-height vertical |
| `prefix + <` / `>` | Move window left / right in the list |
| `prefix + x` | Kill current pane |
| `prefix + z` | Toggle pane zoom (fullscreen) |
| `prefix + {` / `}` | Swap pane with previous / next |
| `prefix + Space` | Cycle through pane layouts |

### Mouse & Copy (vi mode)

- Mouse mode is **on** — click to select panes, drag borders to resize, scroll to enter copy mode.
- Copy-mode uses **vi keys**.

| Shortcut | Action |
|----------|--------|
| `prefix + [` | Enter copy mode |
| `v` | Start selection (in copy mode) |
| `y` | Yank selection to clipboard (in copy mode) |
| `q` | Quit copy mode |
| `prefix + ]` | Paste yanked text |

On macOS, clipboard is wired through `reattach-to-user-namespace` so yanks land in the system clipboard.

### Other settings worth knowing

- History limit: 64,096 lines
- Focus events enabled
- Escape time: 10 ms

## Git config

- Editor: `nvim`
- Diff tool: `nvimdiff`
- [ghq](https://github.com/x-motemen/ghq) root: `~/.ghq`
- [Git LFS](https://git-lfs.github.com/) enabled
- [cz-git](https://cz-git.qbb.sh/) for conventional commits
- [lazygit](https://github.com/jesseduffield/lazygit) with commitizen integration (`C` key)

### Git Aliases

| Alias | Command |
|-------|---------|
| `git a` | Interactive add with peco |
| `git d` | `diff` |
| `git co` | `checkout` |
| `git ci` | `commit` |
| `git ca` | `commit -a` |
| `git ps` | Push current branch to origin |
| `git pl` | Pull current branch |
| `git st` | `status` |
| `git br` | `branch` |
| `git ba` | `branch -a` |
| `git hist` | Pretty log graph |
| `git llog` | Log graph with name-status |
| `git df` | Interactive diff with peco |
| `git find` | Search commits with peco |
| `git edit-unmerged` | Open conflicted files in editor |
| `git add-unmerged` | Stage conflicted files |

## macOS defaults

`.macos` is a **minimal, snapshot-style** script (no `sudo`, no system-level writes) that encodes only this machine's deliberate deltas from macOS defaults. It replaced the inherited 978-line craftzdog/mathiasbynens kitchen-sink (recoverable from git history). It applies three things:

- **Language & region**: English (Thailand) + Thai — `AppleLocale=en_TH`, `AppleLanguages=(en-TH, th-TH)` (implies metric/Celsius; log out/in to apply)
- **Trackpad**: tap to click (built-in + Bluetooth trackpad)
- **Launcher hotkeys**: rebind Spotlight ("Show Spotlight search") from `⌘ Space` to `⌥ Space`, freeing `⌘ Space` for [Alfred](https://www.alfredapp.com/)

> On macOS 26 (Tahoe) the Spotlight hotkey may need a one-time System Settings toggle to go live, and Alfred's `⌘ Space` must be set by hand in Alfred Settings (it's GUI-only). See the comments in `.macos`.

## Scripts

| Script | Description |
|--------|-------------|
| `.macos` | Configure macOS system defaults |
| `.scripts/ide` | Create tmux IDE split layout |
| `update_sudo_tid.sh` | Enable TouchID for sudo (with pam_reattach for tmux) |

## Other Config Files

- `.editorconfig` - 2-space indent, UTF-8, LF line endings
- `.czrc` - cz-git adapter for conventional commits
- `.config/lazygit/config.yml` - lazygit with commitizen (`git cz`)

## Local AI coding implementor

An **architect → implementor** split for offline, zero-cost coding: **Claude Code designs** (plans the change and writes a spec), and a **local open model implements** it (edits your repo autonomously). The diff is left uncommitted so you review before it becomes real. Everything after the design step runs on-device — no internet, no API cost.

Installed on demand (the model pull is ~25 GB, so it's gated behind a flag):

```bash
./install.sh --with-localai
```

This installs [Ollama](https://ollama.com/) + [OpenCode](https://opencode.ai/), pulls the model, and rebuilds it with a baked-in 65536-token context (Ollama's 4K default silently truncates agent loops).

### Components

| Part | Tool | Role |
|------|------|------|
| Runtime | [Ollama](https://ollama.com/) (native, Homebrew) | Serves the model on the GPU (llama.cpp Metal backend) |
| Model | `devstral-small-2:24b` (Mistral Devstral, q8_0) | The implementor — reliable native tool-calling, the default |
| Harness | [OpenCode](https://opencode.ai/) | Autonomous agent that reads/edits files; **never auto-commits** |
| Config | `.config/opencode/opencode.json` (tracked + symlinked) | Ollama provider, Devstral default, `permission.edit: allow` |

An optional benchmark challenger, `qwen3.6-35b-a3b` (Qwen3.6 35B-A3B MoE), can be added by hand — see `CLAUDE.md` for the install (its `ollama pull` 400s on import, so it's built from the downloaded blob instead).

### How to use it — Claude designs, local model implements

```bash
# 0. Start the runtime (once per boot)
brew services start ollama

# 1. DESIGN — in Claude Code, plan the change and write a spec, e.g. .task-spec.md.
#    Put durable, repo-wide conventions in the repo's root AGENTS.md (auto-loaded).

# 2. IMPLEMENT — hand the spec to the local model (defaults to Devstral, no -m needed):
opencode run "$(cat .task-spec.md)"

# 3. REVIEW — the edits land uncommitted in the working tree:
git diff          # good?  commit with `git cz`
                  # wrong? refine the spec and re-run, or fix by hand
```

- **One model, no flags** — `opencode run` uses Devstral by default; Qwen only loads if you pass `-m ollama/qwen3.6-35b-a3b`.
- **Never auto-commits** — the diff always waits for your review.
- **Local + free** after the design step.

### Managing the runtime

| Command | Description |
|---------|-------------|
| `ollama list` | List installed models |
| `ollama ps` | Show what's loaded (want `100% GPU`, `65536` context) |
| `ollama run devstral-small-2:24b` | Chat with the model directly in the terminal |
| `ollama stop <model>` | Unload it from memory now |
| `brew services start ollama` | Start the Ollama daemon |

Measured on an M5 Max (48 GB): ~860 tok/s reading the spec, ~21 tok/s writing code, with a one-time ~8 s model load after ~5 min idle.

## Claude Code

Configuration for [Claude Code](https://claude.com/claude-code) is tracked and symlinked so it syncs to a fresh machine via `install.sh`. Local state and secrets stay per-machine in the gitignored `~/.claude/settings.local.json`.

- **`.claude/statusline.sh`** — a custom status line ("Beacon"): model name, ghq-shortened `org/repo`, branch + dirty `*` + ahead/behind, a **work** badge for pttep repos, live context-window `%`, session cost, and lines `+/-`. Flat truecolor on the terminal's translucent background — no powerline glyphs. Needs `jq`. Test it with `echo '{...}' | ~/.claude/statusline.sh`.
- **`.claude/settings.json`** — tracked + symlinked, so theme, hooks, enabled plugins, and the `statusLine` block all sync automatically (no hand-editing on a new machine).

### Work vs personal in the status line

The status line distinguishes the two accounts in two independent ways:

1. **The yellow `work` badge** — pure repo detection, no config. It appears when the current repo belongs to a work org: the `origin` remote uses the `github.com-pttep` SSH host or a `pttep-pcl`/`pttep-fusionsol` org, or the ghq path starts with one of those orgs. Personal repos show no badge at all (silence = personal).
2. **The `acct` spend segment** — shown **only when the active account is work**, because the org (work) account has a Cost API while the personal account is an individual account and has none. It renders month-to-date API spend vs your budget plus today's spend, e.g. `acct 62% $312/$500 · today $12` (the `%` turns yellow ≥ 70, red ≥ 90). Other states: `acct …` fetching · `acct ⚠` no/invalid Admin key · `acct ✗` API error.
3. **The `day` daily-cap segment** — shown only in **work-billed sessions** (the repo was stamped by `cc-auth work`, so `ANTHROPIC_API_KEY` is in the session's environment). Renders today's local spend vs the `WORK_DAILY_BUDGET` cap, e.g. `day $37.50/$100`, turning yellow ≥ 80% and red ≥ 100% — the same thresholds where the `cc-work-limit` hook warns and then blocks. Unlike `acct`, this needs no Admin key and no network: the status line itself records each session's cost into a local ledger (`~/.claude/cache/work-day/<date>/<session_id>`) and sums it. Resets at local midnight; counts only Claude Code usage on this machine.

Which account is "active" is decided by `~/.claude/statusline-account`, written by `cc-acct`:

- `cc-acct auto` (the default when the file is absent) — follow the repo: work badge ⇒ work, otherwise personal.
- `cc-acct work` / `cc-acct personal` — force it regardless of repo.
- `cc-acct status` — show the current setting.

So in a personal repo you normally see no badge and no `acct` segment; in a pttep repo you see both. The spend data comes from a non-secret cache (`~/.claude/cache/credits-work.json`) that `cc-credits-refresh` rewrites in the background when it's older than 10 minutes — the status line itself never touches the Admin key or the network. Note this is display-only: it does **not** change which credentials Claude Code uses — that's `cc-auth` (below).

### Credential & spend scripts (`.scripts/`, on `$PATH`)

| Script | Description |
|--------|-------------|
| `cc-auth [work\|personal\|status]` | Switch which **credentials** Claude Code authenticates with, **per repo** — Claude.ai subscription is the default everywhere; the work API key + gateway are stamped into a single repo's `.claude/settings.local.json` on demand. The secret lives only in `~/.claude/work-auth.json` (chmod 600, never committed). |
| `cc-acct [work\|personal\|auto\|status]` | Pick which account the status line shows API **spend** for (`auto` = by repo: pttep → work, else personal). |
| `cc-credits-refresh [work]` | Fetch month-to-date org API spend (Anthropic Cost API — needs an Admin key) into a non-secret cache the status line reads. |
| `cc-work-limit` | Claude Code **hook** (auto-registered via the tracked `settings.json`, not a CLI) enforcing the work **$100/day cap**: warns at ≥ 80% of `WORK_DAILY_BUDGET`, blocks new prompts **and denies tool calls** at ≥ 100%. Reads the same local ledger as the `day` segment; personal/subscription sessions are never touched. The budget is one more entry in `~/.claude/work-auth.json`, stamped per-repo by `cc-auth work` (re-run it once in repos stamped earlier); set it to `0` to disable enforcement. |

## Syncing with upstream (craftzdog)

This repo is forked from [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public). To pull in new changes from upstream:

### One-time setup

```bash
# Add the upstream remote (only needed once)
git remote add craftzdog https://github.com/craftzdog/dotfiles-public.git
```

### Update workflow

```bash
# 1. Fetch latest changes from upstream
git fetch craftzdog

# 2. Make sure you're on your master branch
git checkout master

# 3. Review what's changed upstream before merging
git log master..craftzdog/master --oneline

# 4. Merge upstream changes into your branch
git merge craftzdog/master --no-commit

# 5. Review the merge — resolve conflicts and discard changes you don't want
git diff --staged

# 6. Commit the merge
git commit -m "feat: sync with upstream craftzdog/dotfiles-public"

# 7. Push to your GitHub repo
git push origin master
```

### Tips

- Use `--no-commit` on merge so you can review and cherry-pick only the changes you want before committing.
- If a merge has too many conflicts, you can abort with `git merge --abort` and cherry-pick individual commits instead:
  ```bash
  git log craftzdog/master --oneline   # find the commit hash you want
  git cherry-pick <commit-hash>
  ```
- Keep your personal customizations (`.zshrc`, custom functions, etc.) on `master` and only pull Neovim/tmux updates from upstream to minimize conflicts.

## Credits

Forked from [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public) by [Takuya Matsuyama](https://github.com/craftzdog).
