# nenoteerawat's dotfiles

**Warning**: Don't blindly use my settings unless you know what that entails. Use at your own risk!

## Contents

- [Zsh config](#zsh-setup-macos) (primary shell)
- [Fish config](#fish-setup)
- [Neovim config](#neovim-setup)
- [tmux config](#tmux-setup)
- [Git config](#git-config)
- [macOS defaults](#macos-defaults)
- [Scripts](#scripts)

## Neovim setup

Neovim configuration based on [LazyVim](https://www.lazyvim.org/) with [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim) theme (transparent).

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
| [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim) | Colorscheme (transparent) |
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
- [Nix](https://nixos.org/) / [DevBox](https://www.jetify.com/devbox) - Reproducible dev environments
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

`.macos` script configures macOS system preferences:

- **General**: Disable auto-correct, smart quotes, smart dashes, auto-capitalization
- **Keyboard**: Fast key repeat (1), short initial delay (10), disable press-and-hold
- **Trackpad**: Tap to click, bottom-right corner right-click
- **Dock**: Auto-hide, show only open apps, icon size 36px, no recent apps
- **Finder**: Show path bar, status bar, full POSIX path in title, list view default
- **Screen**: Screenshots to Desktop in PNG, password required immediately after sleep
- **Hot Corners**: Top-left Mission Control, Top-right Desktop, Bottom-left Screen saver
- **Energy**: Display sleep 15min, no sleep on charger, 5min on battery
- **Safari**: Develop menu enabled, Do Not Track, disable AutoFill
- **Timezone**: Asia/Bangkok

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

## Credits

Forked from [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public) by [Takuya Matsuyama](https://github.com/craftzdog).
