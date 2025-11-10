eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
# Golang PATH
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin

# FZF Style
# Tmux FZF stile
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# ZSH Autocomplete & Autosuggestion & Syntx Highlighting &
#source "$(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
source $HOME/.zprofile

# fzf key bindings and fuzzy completion
FZF_CTRL_T_COMMAND= FZF_ALT_C_COMMAND= source <(fzf --zsh)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

# NVM Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"  # This loads nvm
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# ZSH Auto Complete
# Git Flow CLI
source $HOME/.ghq/github.com/bobthecow/git-flow-completion/git-flow-completion.zsh
# Anguler CLI
source <(ng completion script)
# Atlas CLI
source <(atlas completion zsh)
# Kubectl CLI
source <(kubectl completion zsh)
# Helm CLI
source <(helm completion zsh)
# Google Cloud SDK CLI
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
# Docker CLI
source <(docker completion zsh)
# Trivy CLI
source <(trivy completion zsh)
# Dagger CLI
source <(dagger completion zsh)
# Github CLI
source <(gh completion -s zsh)
# Setup Nix-Shell
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || \
source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
# Setup DevBox Gobal
eval "$(devbox global shellenv --init-hook)"
#compdef gitlab-ci-local
###-begin-gitlab-ci-local-completions-###
#
# yargs command completion script
#
# Installation: /opt/homebrew/bin/gitlab-ci-local completion >> ~/.zshrc
#    or /opt/homebrew/bin/gitlab-ci-local completion >> ~/.zprofile on OSX.
#
_gitlab-ci-local_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" /opt/homebrew/bin/gitlab-ci-local --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gitlab-ci-local_yargs_completions gitlab-ci-local
###-end-gitlab-ci-local-completions-###

# Setup .config for zsh shell
# XDG (where Neovim & Lazy look by default anyway; set explicitly for consistency)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Make sure Mason & other tool shims are discoverable
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# If you use mise/asdf/nvm, ensure their init runs in zsh
# mise
if command -v mise >/dev/null 2>&1; then eval "$(mise activate zsh)"; fi
# nvm (example)
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"

# Custom Function
cdzgit() {
    local selected_ghq
    selected_ghq=$(ghq list | fzf +m --height 50% --preview 'tree -C')
    if [[ -n "$selected_ghq" ]]; then
        # Change to the selected directory
        cd "$HOME/.ghq/$selected_ghq" || return 1
    fi
}
cdznorm() {
    local selected_dir
    input=$1
    if [[ $input = "git" ]]; then
      cdzgit
    elif [[ $input = "pttep" ]]; then
      selected_dir="$HOME/pttep/"
    elif [[ $input = "desk" ]]; then
      selected_dir="$HOME/Desktop/"
    elif [[ $input = "load" ]]; then
      selected_dir="$HOME/Downloads/"
    else
      selected_dir=$input
    fi
    if [[ $input != "git" ]]; then
      selected_dir=$(fd -t d . "$selected_dir" | fzf +m --height 50% --preview 'tree -C {}')
      if [[ -n "$selected_dir" ]]; then
          # Change to the selected directory
          cd "$selected_dir" || return 1
      fi
    fi
}

# Exact port of your fish function
fzf_change_directory() {
  emulate -L zsh
  setopt pipefail

  local ignore_dir='\.git|\.terragrunt-cache|node_modules'

  {
    # 1) Fixed entries (echo, no existence checks — same as fish)
    echo "$HOME/.config"
    echo "$HOME/.ghq/github.com/nenoteerawat/dotfiles"

    # 2) ghq repos: find .../.git then strip '/.git'
    if command -v ghq >/dev/null 2>&1; then
      find "$(ghq root)" -maxdepth 4 -type d -name .git 2>/dev/null | sed 's/\/\.git$//'
    fi

    # 3) Specific groups (match fish: base/* then -maxdepth 1 -type d, then grep -v -E)
    find $HOME/.ghq/gitlab.tools.pttep.com/ep-digital-platform/* -maxdepth 1 -type d 2>/dev/null | grep -v -E "$ignore_dir"
    find $HOME/.ghq/gitlab.tools.pttep.com/aws-digital-platform/* -maxdepth 1 -type d 2>/dev/null | grep -v -E "$ignore_dir"
    find $HOME/.ghq/gitlab.tools.pttep.com/devsecops/* -maxdepth 1 -type d 2>/dev/null | grep -v -E "$ignore_dir"
    find $HOME/.ghq/gitlab.tools.pttep.com/devsecops/* -maxdepth 1 -type d 2>/dev/null | grep -v -E "$ignore_dir"

    # 4) Current dir immediate subdirs → absolute, then ignore
    ls -ad */ 2>/dev/null | perl -pe "s#^#$PWD/#" | grep -v -E "$ignore_dir"
  } | sed -e 's/\/$//' | awk '!a[$0]++' | fzf "$@" | while read -r dir; do
    cd "$dir" # && nvim .
  done
}

# Aliases
alias g="git"
alias ll="eza -l -g --icons"
alias lla="ll -a"
alias llt="ll -T --level=2"
alias llta="llt -a"
alias cdz='cdznorm'
alias vim='nvim'
alias vi='nvim'
alias gcl='gitlab-ci-local'


# Bind Key
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

fzf_change_directory-widget() { zle -I; fzf_change_directory; zle reset-prompt }
zle -N fzf_change_directory-widget
bindkey '^F' fzf_change_directory-widget

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
autoload -Uz compinit && compinit

# FZF-TAB Auto Complete
source ~/.ghq/github.com/Aloxaf/fzf-tab/fzf-tab.plugin.zsh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
complete -o nospace -C /opt/homebrew/bin/terragrunt terragrunt
complete -o nospace -C /opt/homebrew/bin/vault vault
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/nenoteerawat/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
