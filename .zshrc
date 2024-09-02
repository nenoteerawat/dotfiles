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
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Anguler CLI Setup
source <(ng completion script)

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
      selected_dir="~/pttep/" 
    elif [[ $input = "desk" ]]; then
      selected_dir="~/Desktop/"
    elif [[ $input = "load" ]]; then
      selected_dir="~/Downloads/"
    else
      selected_dir=$input
    fi
    if [[ $input != "git" ]]; then
      selected_dir=$(fd -t d . "$input" | fzf +m --height 50% --preview 'tree -C {}')
      if [[ -n "$selected_dir" ]]; then
          # Change to the selected directory
          cd "$selected_dir" || return 1
      fi
    fi
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


# Bind Key
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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
