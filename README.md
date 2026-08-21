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

Fish shell configuration with platform-specific configs (macOS/Linux/Windows). Note: `install.sh` is zsh-only, so the fish tree is secondary to the primary zsh config.

- [Fish shell](https://fishshell.com/)
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

tmux configuration themed to the macOS Terminal "Clear Dark" palette (status bar on `bg=default` to inherit the terminal's translucency, matching the nvim tokyonight remap), with vi mode.

- Prefix key: `Ctrl+t`
- [TPM](https://github.com/tmux-plugins/tpm) - Plugin manager
- [tmux-pain-control](https://github.com/tmux-plugins/tmux-pain-control) - Pane navigation bindings

### tmux Key Bindings

| Key | Action |
|-----|--------|
| `prefix + r` | Reload tmux config |
| `prefix + e` | Kill all panes except current |
| `prefix + g` | Open lazygit in a popup (80% width/height) |
| `prefix + y` | Open Claude Code in a popup (per-directory session) |
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
- Work GitLab (`gitlab.tools.pttep.com`) over HTTPS with a personal access token in the macOS Keychain — setup below

### Work GitLab over HTTPS (token in Keychain)

`gitlab.tools.pttep.com` (work GitLab) clones over HTTPS with a personal access token. The token lives **only in the macOS Keychain** (git's `osxkeychain` credential helper, enabled system-wide by Homebrew git in `/opt/homebrew/etc/gitconfig`) — never in a tracked file. `.gitconfig` carries the non-secret half:

- `[ghq "https://gitlab.tools.pttep.com/"]` → `vcs = git` — self-hosted GitLab isn't in ghq's known-hosts list, so without this `ghq get` can fail VCS detection (the go-import probe needs auth on this instance).
- `[credential "https://gitlab.tools.pttep.com"]` → `username = oauth2` — GitLab accepts any non-blank username with a PAT, so git never prompts for one; the Keychain entry only holds the token.

One-time setup on each machine:

```sh
# 1. Create the token: GitLab → avatar → Preferences → Access Tokens,
#    scope `read_repository` (add `write_repository` to push over HTTPS).

# 2. Store it in the Keychain (read -s keeps it off screen and out of shell history):
read -rs TOKEN   # paste the token, press Enter (nothing echoes)
printf "protocol=https\nhost=gitlab.tools.pttep.com\nusername=oauth2\npassword=%s\n" "$TOKEN" | git credential approve
unset TOKEN

# 3. Verify — should list refs with no prompt:
git ls-remote https://gitlab.tools.pttep.com/<group>/<repo>.git
```

Then either form clones silently and lands at `~/.ghq/gitlab.tools.pttep.com/<group>/<repo>`:

```sh
ghq get https://gitlab.tools.pttep.com/<group>/<repo>
ghq get gitlab.tools.pttep.com/<group>/<repo>     # scheme-less shorthand defaults to https
```

When the token expires or is rotated (git starts failing with HTTP 401), drop the stale entry and re-run step 2 with the new token:

```sh
printf "protocol=https\nhost=gitlab.tools.pttep.com\n" | git credential reject
```

SSH to the same host is configured separately in `.ssh/config`; HTTPS + token is the path when SSH isn't an option.

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

`~/.scripts` is a whole-directory symlink into the repo and is on `$PATH`, so everything below is a bare command from any repo.

| Script | Description |
|--------|-------------|
| `.macos` | Configure macOS system defaults |
| `.scripts/ide` | Create tmux IDE split layout |
| `.scripts/cc-auth` | Switch Claude Code **credentials** per repo (work API key vs personal subscription) — see [Claude Code](#claude-code) |
| `.scripts/cc-work-limit` | Claude Code hook — enforces the work $100/day cap — see [Claude Code](#claude-code) |
| `.scripts/cc-credits-refresh` | Background fetch of month-to-date org API spend into the status-line cache |
| `.scripts/vpn` | Switch between Cloudflare WARP (corporate) and Tailscale — one tunnel at a time — see [VPN switch](#vpn-switch-vpn) |
| `update_sudo_tid.sh` | Enable TouchID for sudo (with pam_reattach for tmux) |

### VPN switch (`vpn`)

Cloudflare WARP (the corporate Zero Trust client) and Tailscale can't run together on this machine: WARP's gateway blocks tailscaled's control-plane traffic (login never completes — `controlplane.tailscale.com` dials fail with "no route to host" / "connection refused"), and `warp-cli disconnect` is **policy-locked**. The only local off-switch is unloading WARP's root launchd daemon, so each switch costs one sudo (TouchID) prompt:

```bash
vpn ts       # stop the WARP daemon, verify DNS recovered, tailscale up
vpn warp     # tailscale down (stays logged in), bootstrap the WARP daemon back
vpn status   # no sudo — report both sides
```

Both switches are idempotent. The first-ever `vpn ts` prints a Tailscale login URL; after that the login persists and switching is instant. **Reboot (or an MDM re-push) restores WARP** — the plist stays in `/Library/LaunchDaemons`, so the machine's default state remains "corporate" and you just run `vpn ts` again. If WARP reappears on its own within minutes, MDM is re-launching it; the durable fix is asking IT for Split Tunnel exclusions (`*.tailscale.com`, `100.64.0.0/10`), not this script.

## Other Config Files

- `.editorconfig` - 2-space indent, UTF-8, LF line endings
- `.czrc` - cz-git adapter for conventional commits
- `.config/lazygit/config.yml` - lazygit with commitizen (`git cz`)

## Claude Code

Configuration for [Claude Code](https://claude.com/claude-code) is tracked and symlinked so it syncs to a fresh machine via `install.sh`. Local state and secrets stay per-machine in the gitignored `~/.claude/settings.local.json`.

- **`.claude/statusline.sh`** — a custom status line ("Beacon"): model name, ghq-shortened `org/repo`, branch + dirty `*` + ahead/behind, a **work** badge for pttep repos, a context-usage bar + absolute-token `ctx` readout, session cost + duration, lines `+/-`. Flat truecolor on the terminal's translucent background — no powerline glyphs. Needs `jq`. Test it with `echo '{...}' | ~/.claude/statusline.sh`.
- **`.claude/settings.json`** — tracked + symlinked, so theme, hooks, enabled plugins, and the `statusLine` block all sync automatically (no hand-editing on a new machine).

### Context window reference

[`docs/claude-context-windows.md`](docs/claude-context-windows.md) is a dated snapshot of Claude 5-family context-window sizes, compaction defaults, and pricing, adversarially verified against primary Anthropic sources (13/13 claims confirmed as of 2026-08-06). Its headline finding: no source, official or third-party, publishes a numeric effective-context or quality-degradation threshold for any Claude 5-family model.

### Work vs personal in the status line

The status line distinguishes the two accounts in several independent ways:

1. **The yellow `work` badge** — pure repo detection, no config. It appears when the current repo belongs to a work org: the `origin` remote uses the `github.com-pttep` SSH host or a `pttep-pcl`/`pttep-fusionsol` org, or the ghq path starts with one of those orgs. Personal repos show no badge at all (silence = personal).
2. **The `acct` spend segment** — shown **only in work-billed sessions** (same detection as `day` below: the repo was stamped by `cc-auth work`), because the org (work) account has a Cost API while the personal account is an individual account and has none. It renders month-to-date API spend vs your budget plus today's spend, e.g. `acct 62% $312/$500 · today $12` (the `%` turns yellow ≥ 70, red ≥ 90). Other states: `acct …` fetching · `acct ⚠` no/invalid Admin key · `acct ✗` API error.
3. **The `lim` usage-limit segment** — the **personal-side** monitor: in subscription sessions it shows the Claude.ai plan's rate-limit windows from `/usage`, e.g. `lim 5h 24% · 7d 61%` (yellow ≥ 70, red ≥ 90; a window ≥ 70% also shows its reset — `→14:30` for the 5-hour window, `→Tue` for weekly ones). The data arrives free on the status-line stdin (`rate_limits`, Pro/Max only, present after the session's first API response) — no network, no tokens, no cache. Windows are rendered generically, so if Claude Code adds the 7-day Opus limit to the JSON it appears automatically as `7d·op`.
4. **The `day` daily-cap segment** — shown only in **work-billed sessions** (the repo was stamped by `cc-auth work`, so `ANTHROPIC_API_KEY` is in the session's environment). Renders today's local spend vs the `WORK_DAILY_BUDGET` cap, e.g. `day $37.50/$100`, turning yellow ≥ 80% and red ≥ 100% — the same thresholds where the `cc-work-limit` hook warns and then blocks. Unlike `acct`, this needs no Admin key and no network: the status line itself records each session's cost into a local ledger (`~/.claude/cache/work-day/<date>/<session_id>`) and sums it. Resets at local midnight; counts only Claude Code usage on this machine.

Which account is "active" **follows the auth state** — there is no separate display toggle. `cc-auth work` stamps the work credentials into the repo, which makes its sessions work-billed, which makes the status line show the `day` + `acct` spend segments; `cc-auth personal` strips them and the segments disappear. One switch drives both billing and display. *(The old `cc-acct` script and its `~/.claude/statusline-account` override file were removed when this was merged into `cc-auth`.)*

So in a personal/subscription session you see no `acct`/`day` segments (and in a personal repo no badge either); in a `cc-auth work`-stamped repo you see all of them. The spend data comes from a non-secret cache (`~/.claude/cache/credits-work.json`) that `cc-credits-refresh` rewrites in the background when it's older than 10 minutes — the status line itself never touches the Admin key or the network.

### Credential, model & spend scripts (`.scripts/`, on `$PATH`)

| Script | Description |
|--------|-------------|
| `cc-auth [work [--daily-budget N]\|personal\|status]` | Switch which **credentials** Claude Code authenticates with, **per repo** — Claude.ai subscription is the default everywhere; the work API key + gateway are stamped into a single repo's `.claude/settings.local.json` on demand. `--daily-budget N` (or bare `cc-auth work 50`) sets the global `WORK_DAILY_BUDGET` daily cap in `work-auth.json` before stamping (`0` disables enforcement). The status line's spend segments follow this same state automatically. The secret lives only in `~/.claude/work-auth.json` (chmod 600, never committed). |
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
