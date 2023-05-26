eval "$(/opt/homebrew/bin/brew shellenv)"
if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end
