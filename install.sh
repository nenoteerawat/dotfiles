#!/usr/bin/env bash
#
# install.sh — bootstrap this dotfiles repo on a fresh macOS machine, using ZSH.
#
# Installs every tool the config references, links the configs into place, and
# leaves you with a working zsh + starship + tmux + neovim setup. Fish is
# intentionally skipped — all functionality is provided by the zsh config.
#
# Safe to re-run: every step checks before acting (idempotent). Existing real
# files at a link target are backed up to "<file>.bak.<timestamp>".
#
# Usage:
#   ./install.sh [options]
#
# Tiers (default = CORE + RECOMMENDED + NPM + CASKS + links + missing-file fixes):
#   --minimal       Only what zsh needs to load cleanly with all functions.
#   --no-casks      Skip GUI casks (ghostty + Nerd Fonts).
#   --no-chsh       Don't set zsh as the login shell.
#   --dev-extras    Also install atlas (ariga tap) + @angular/cli.
#   --with-cloud    Install the google-cloud-sdk cask (fixes the unguarded
#                   gcloud source in .zshrc lines 60-61).
#   --with-docker   Install the docker-desktop cask.
#   --with-goland   Install the GoLand cask (JetBrains, license-gated).
#   --with-touchid  Run ./update_sudo_tid.sh (TouchID for sudo; needs sudo).
#   --with-macos    Run ./.macos system tweaks (needs sudo; invasive).
#   --sync-nvim     Headless LazyVim plugin sync after linking.
#   -h, --help      Show this help.
#
set -euo pipefail

# --------------------------------------------------------------------------- #
# Config / flags
# --------------------------------------------------------------------------- #
MINIMAL=0; CASKS=1; DO_CHSH=1; DEV_EXTRAS=0
WITH_CLOUD=0; WITH_DOCKER=0; WITH_GOLAND=0
WITH_TOUCHID=0; WITH_MACOS=0; SYNC_NVIM=0

for arg in "$@"; do
  case "$arg" in
    --minimal)      MINIMAL=1 ;;
    --no-casks)     CASKS=0 ;;
    --no-chsh)      DO_CHSH=0 ;;
    --dev-extras)   DEV_EXTRAS=1 ;;
    --with-cloud)   WITH_CLOUD=1 ;;
    --with-docker)  WITH_DOCKER=1 ;;
    --with-goland)  WITH_GOLAND=1 ;;
    --with-touchid) WITH_TOUCHID=1 ;;
    --with-macos)   WITH_MACOS=1 ;;
    --sync-nvim)    SYNC_NVIM=1 ;;
    -h|--help)      awk 'NR==1{next} /^#/{sub(/^# ?/,"");print;next} {exit}' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done
[ "$MINIMAL" = 1 ] && CASKS=0

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TS="$(date +%Y%m%d%H%M%S)"
WARNINGS=()

# --------------------------------------------------------------------------- #
# Output helpers
# --------------------------------------------------------------------------- #
if [ -t 1 ]; then BLU=$'\033[34m'; GRN=$'\033[32m'; YLW=$'\033[33m'; RED=$'\033[31m'; DIM=$'\033[2m'; RST=$'\033[0m'
else BLU=; GRN=; YLW=; RED=; DIM=; RST=; fi
step() { printf '\n%s==>%s %s\n' "$BLU" "$RST" "$1"; }
ok()   { printf '  %s✓%s %s\n' "$GRN" "$RST" "$1"; }
skip() { printf '  %s·%s %s\n' "$DIM" "$RST" "$1"; }
warn() { printf '  %s!%s %s\n' "$YLW" "$RST" "$1"; WARNINGS+=("$1"); }
die()  { printf '%sERROR:%s %s\n' "$RED" "$RST" "$1" >&2; exit 1; }

# --------------------------------------------------------------------------- #
# 0. Preflight
# --------------------------------------------------------------------------- #
step "Preflight"
[ "$(uname -s)" = "Darwin" ] || die "This config is macOS-only."
[ "$(id -u)" -ne 0 ] || die "Do not run as root. Run as your normal user; sudo is requested only when needed."
if [ "$(uname -m)" = "arm64" ]; then
  BREW_PREFIX="/opt/homebrew"; ok "Apple Silicon detected (brew prefix $BREW_PREFIX)"
else
  BREW_PREFIX="/usr/local"
  warn "Intel Mac: .zshrc hardcodes /opt/homebrew (brew shellenv, terraform/vault completions, pam_reattach). You'll need to adjust those paths manually."
fi
ok "Repo: $REPO"

# Xcode Command Line Tools (cc/make for treesitter + fzf-native)
if xcode-select -p >/dev/null 2>&1; then
  ok "Xcode Command Line Tools present"
else
  step "Installing Xcode Command Line Tools (a GUI dialog may appear — finish it, then re-run)"
  xcode-select --install || true
  die "Re-run ./install.sh after the Command Line Tools finish installing."
fi

# --------------------------------------------------------------------------- #
# 1. Homebrew
# --------------------------------------------------------------------------- #
step "Homebrew"
if [ -x "$BREW_PREFIX/bin/brew" ]; then
  ok "Homebrew already installed"
else
  warn "Installing Homebrew (will prompt for your password)…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

# --------------------------------------------------------------------------- #
# Install helpers
# --------------------------------------------------------------------------- #
brewf() { # install formulae, skip if present
  local f
  for f in "$@"; do
    if brew list --formula "${f##*/}" >/dev/null 2>&1; then skip "$f (formula present)"
    else brew install "$f" && ok "$f"; fi
  done
}
brewc() { # install casks, skip if present
  local c
  for c in "$@"; do
    if brew list --cask "$c" >/dev/null 2>&1; then skip "$c (cask present)"
    else brew install --cask "$c" && ok "$c"; fi
  done
}
npmg() { # install npm globals, skip if present
  local p
  for p in "$@"; do
    if npm ls -g --depth=0 "$p" >/dev/null 2>&1; then skip "$p (npm global present)"
    else npm install -g "$p" && ok "$p"; fi
  done
}

# --------------------------------------------------------------------------- #
# 2. Core formulae (zsh loads cleanly + all functions work)
# --------------------------------------------------------------------------- #
step "Core formulae"
brewf zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
      fzf starship eza fd \
      git git-lfs neovim tmux \
      mise ghq \
      tree coreutils reattach-to-user-namespace lazygit
git lfs install --skip-repo >/dev/null 2>&1 && ok "git-lfs hooks registered" || true

# --------------------------------------------------------------------------- #
# 3. Recommended dev CLIs (silence the unguarded completion sources in .zshrc)
# --------------------------------------------------------------------------- #
if [ "$MINIMAL" = 1 ]; then
  step "Recommended dev CLIs"; skip "--minimal: skipping kubectl/helm/gh/terraform/… (their completion lines will print harmless 'command not found' on shell start)"
else
  step "Recommended dev CLIs"
  # terraform & vault are no longer in homebrew-core (HashiCorp BSL relicense) —
  # they live in hashicorp/tap. brewf taps it automatically via the full path.
  brewf kubernetes-cli helm gh trivy k3d terragrunt hub peco \
        hashicorp/tap/terraform hashicorp/tap/vault
fi

# Optional dev extras
if [ "$DEV_EXTRAS" = 1 ]; then
  step "Dev extras"
  brewf ariga/tap/atlas
fi

# --------------------------------------------------------------------------- #
# 4. GUI casks (terminal + font)
# --------------------------------------------------------------------------- #
if [ "$CASKS" = 1 ]; then
  step "Casks (terminal + Nerd Fonts)"
  brewc ghostty font-plemol-jp-nf font-hack-nerd-font
else
  step "Casks"; skip "skipped (--no-casks / --minimal). ghostty + font-plemol-jp-nf + font-hack-nerd-font not installed."
fi
[ "$WITH_CLOUD" = 1 ]  && { step "Google Cloud SDK"; brewc google-cloud-sdk; }
[ "$WITH_DOCKER" = 1 ] && { step "Docker Desktop"; brewc docker-desktop; }
[ "$WITH_GOLAND" = 1 ] && { step "GoLand"; brewc goland; }

# --------------------------------------------------------------------------- #
# 5. fzf-tab (ghq clone) + TPM (git clone)
# --------------------------------------------------------------------------- #
step "Zsh plugin: fzf-tab (ghq clone)"
FZFTAB="$HOME/.ghq/github.com/Aloxaf/fzf-tab"
if [ -d "$FZFTAB/.git" ]; then ok "fzf-tab present"
else ghq get Aloxaf/fzf-tab && ok "cloned fzf-tab"; fi

step "tmux plugin manager (TPM)"
TPM="$HOME/.config/tmux/plugins/tpm"
if [ -d "$TPM/.git" ]; then ok "TPM present"
else mkdir -p "$(dirname "$TPM")"; git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM" && ok "cloned TPM"; fi

# --------------------------------------------------------------------------- #
# 6. Symlinks — PER AUTHORED FILE (tracked files only), zsh-centric.
#    Each tracked file at repo path X is linked to ~/X; the containing
#    ~/.config/* directories stay REAL, so tool-generated files (nvim
#    lazy-lock.json/lazyvim.json, tmux plugins/, Mason, lazygit state.yml)
#    land in ~/.config and never pollute this repo. Driven by `git ls-files`,
#    so the link set is exactly the config you authored.
# --------------------------------------------------------------------------- #
step "Linking authored config files (per-file; tool-generated files stay out of the repo)"

HOME_FILES=(.zshrc .gitconfig .czrc update_sudo_tid.sh .ssh/config .claude/statusline.sh .claude/settings.json)
CONFIG_DIRS=(.config/nvim .config/tmux .config/lazygit .config/mise .config/ghostty .scripts)

link_one() { # link_one <repo-relative-path>  ->  ~/<same-path>
  local rel="$1" src="$REPO/$1" dst="$HOME/$1"
  [ -e "$src" ] || { warn "missing in repo, skipped: $rel"; return; }
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then ok "$rel"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then mv "$dst" "$dst.bak.$TS"; warn "backed up $dst -> $dst.bak.$TS"; fi
  ln -s "$src" "$dst"; ok "$rel"
}

ensure_real_dir() { # migrate a legacy whole-dir symlink back to a real directory
  local dst="$HOME/$1"
  if [ -L "$dst" ]; then rm "$dst"; warn "removed legacy whole-dir symlink $dst (rebuilding as real dir)"; fi
  mkdir -p "$dst"
}

for f in "${HOME_FILES[@]}"; do link_one "$f"; done
for d in "${CONFIG_DIRS[@]}"; do
  ensure_real_dir "$d"
  n=0
  while IFS= read -r rel; do link_one "$rel"; n=$((n+1)); done < <(git -C "$REPO" ls-files -- "$d")
  [ "$n" -eq 0 ] && warn "no tracked files under $d (nothing linked)"
done
skip "fish config NOT linked (you chose zsh)"
skip ".macos NOT linked (run-once script; use --with-macos)"

# --------------------------------------------------------------------------- #
# 7. Fix unguarded sources in .zshrc that error on a fresh machine
# --------------------------------------------------------------------------- #
step "Creating files .zshrc sources unconditionally"
for f in "$HOME/.zprofile" "$HOME/.git-flow-completion.zsh"; do
  if [ -e "$f" ]; then ok "$f present"
  else : > "$f"; ok "created empty $f (prevents a startup 'no such file' error)"; fi
done

# --------------------------------------------------------------------------- #
# 7b. Claude Code status line — API-spend credits
#     cache dir + a chmod-600 credential template (NEVER committed; lives in
#     $HOME). The "acct" segment needs an Admin API key (sk-ant-admin01-…);
#     a regular sk-ant-api… key is rejected by the Cost API. See CLAUDE.md.
# --------------------------------------------------------------------------- #
step "Claude Code status line credits (cache dir + credential template)"
mkdir -p "$HOME/.claude/cache"
CRED="$HOME/.claude/statusline-credits.env"
if [ -e "$CRED" ]; then ok "credential file present ($CRED)"
else
  ( umask 077; cat > "$CRED" <<'CREDEOF'
# Claude Code status line — API spend credentials. NEVER commit this file.
# Cost/usage needs an ADMIN key (sk-ant-admin01-...): Console -> Settings ->
# API keys -> Admin keys (org admin role). A regular sk-ant-api... key is rejected.
WORK_ADMIN_KEY="REPLACE-with-sk-ant-admin01-..."
WORK_MONTHLY_BUDGET="500"
CREDEOF
  )
  chmod 600 "$CRED"
  warn "seeded $CRED (chmod 600) — add your Admin key to enable the 'acct' spend segment"
fi

# --------------------------------------------------------------------------- #
# 8. mise runtimes (bun, ghq, node, python, ruby, rust)
# --------------------------------------------------------------------------- #
step "mise runtimes"
# Build deps for runtimes mise compiles from source. Ruby's psych (YAML)
# extension needs libyaml's yaml.h or the whole ruby build fails; readline
# gives irb line-editing. (node/python come precompiled, so they need nothing.)
brewf libyaml readline
mise trust "$HOME/.config/mise/config.toml" >/dev/null 2>&1 || true
if mise install; then
  ok "mise install complete"
else
  warn "mise install reported failures (a source-compiled runtime may have failed — see output above)."
  warn "Re-run 'mise install' after resolving; for ruby specifically, 'mise settings ruby.compile=false' switches to precompiled binaries."
fi
export PATH="$HOME/.local/share/mise/shims:$PATH"   # make node/npm available for step 9

# --------------------------------------------------------------------------- #
# 9. npm globals (commit workflow + function-backing CLIs)
# --------------------------------------------------------------------------- #
step "npm globals"
if command -v npm >/dev/null 2>&1; then
  if [ "$MINIMAL" = 1 ]; then npmg commitizen cz-git
  else npmg commitizen cz-git sparo gitlab-ci-local; fi
  [ "$DEV_EXTRAS" = 1 ] && npmg @angular/cli
  warn "gcl completion in .zshrc hardcodes /opt/homebrew/bin/gitlab-ci-local; the npm install lands under mise's shims, so completion (not the gcl function) may not fire. 'brew install gitlab-ci-local' if you want the completion."
else
  warn "npm not found even after mise install — install node (mise install node) then run: npm i -g commitizen cz-git sparo gitlab-ci-local"
fi

# --------------------------------------------------------------------------- #
# 10. Default shell -> zsh
# --------------------------------------------------------------------------- #
if [ "$DO_CHSH" = 1 ]; then
  step "Default login shell"
  if [ "${SHELL:-}" = "/bin/zsh" ] || [ "${SHELL:-}" = "$(command -v zsh)" ]; then ok "already zsh"
  else
    grep -q '^/bin/zsh$' /etc/shells || echo "/bin/zsh" | sudo tee -a /etc/shells >/dev/null
    chsh -s /bin/zsh && ok "login shell set to /bin/zsh (re-login to take effect)" || warn "chsh failed; run 'chsh -s /bin/zsh' manually"
  fi
fi

# --------------------------------------------------------------------------- #
# 11. Optional one-shot system steps
# --------------------------------------------------------------------------- #
if [ "$WITH_TOUCHID" = 1 ]; then
  step "TouchID for sudo"
  brewf pam-reattach
  ( cd "$REPO" && ./update_sudo_tid.sh ) && ok "TouchID-for-sudo configured"
fi
if [ "$WITH_MACOS" = 1 ]; then
  step "macOS system defaults (./.macos)"
  ( cd "$REPO" && ./.macos ) && ok ".macos applied (some changes need logout/restart)"
fi
if [ "$SYNC_NVIM" = 1 ]; then
  step "LazyVim headless sync (first run downloads plugins + Mason tools; slow)"
  nvim --headless "+Lazy! sync" +qa 2>/dev/null && ok "Lazy sync done" || warn "nvim sync hit an error; just open nvim and run :Lazy sync / :Mason"
fi

# --------------------------------------------------------------------------- #
# Done — report + manual follow-ups
# --------------------------------------------------------------------------- #
step "Done"
ok "Open a new terminal (or 'exec zsh') to load the new shell."
cat <<EOF

${BLU}Manual follow-ups this script can't automate:${RST}
  • tmux:    start tmux, press ${GRN}Ctrl+t then I${RST} to install plugins (tmux-pain-control) via TPM.
  • nvim:    first launch bootstraps LazyVim + Mason; run ${GRN}:Lazy sync${RST}, ${GRN}:Mason${RST}. (or re-run with --sync-nvim)
  • copilot: ${GRN}:Copilot auth${RST} (needs a Copilot subscription) for copilot.lua.
  • claude:  install + auth the Claude Code CLI for the nvim <leader>a* and tmux prefix+y integrations.
  • cert:    place the work Cloudflare CA at ${GRN}~/.ssh/gateway-ca-cloudflare.pem${RST} (NODE_EXTRA_CA_CERTS, .zshrc:10).
  • work:    clone the pttep GitLab groups under ~/.ghq/gitlab.tools.pttep.com/ for the Ctrl+F picker (needs VPN).

${BLU}Known .zshrc rough edges (not fixed by this script):${RST}
  • Lines 60-61 source the gcloud SDK ${YLW}unconditionally${RST} — without it the shell errors on start.
    Fix: re-run with ${GRN}--with-cloud${RST}, or guard those two lines with a 'command -v gcloud' check.
  • Line 74 (devbox) and lines 71-72 (nix) also run unconditionally and error if those tools are absent.
    Install them, or comment the lines out.
  • Line 7 GoLand PATH is missing a leading slash ('Applications/…' should be '/Applications/…').
EOF

if [ "${#WARNINGS[@]}" -gt 0 ]; then
  printf '\n%sReview these warnings:%s\n' "$YLW" "$RST"
  for w in "${WARNINGS[@]}"; do printf '  ! %s\n' "$w"; done
fi
