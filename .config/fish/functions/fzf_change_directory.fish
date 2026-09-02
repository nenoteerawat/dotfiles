function _fzf_change_directory
    fzf | perl -pe 's/([ ()])/\\\\$1/g' | read foo
    if [ $foo ]
        builtin cd $foo
        commandline -r ''
        commandline -f repaint
    else
        commandline ''
    end
end

function fzf_change_directory
    begin
        set ignore_dir '\.git|\.terragrunt-cache|node_modules'
        echo $HOME/.config
        echo $HOME/.ghq/github.com/nenoteerawat/dotfiles
        find $(ghq root) -maxdepth 4 -type d -name .git | sed 's/\/\.git//'
        # find the group dir directly, not "dir/*": a missing/empty group
        # makes that bare wildcard abort with "No matches for wildcard",
        # printed past this line's own 2>/dev/null (same failure class as
        # zsh's NOMATCH — expansion fails before find, and its redirect,
        # ever runs). mindepth 1/maxdepth 2 reproduces the old depth.
        find "$HOME/.ghq/gitlab.tools.pttep.com/ep-digital-platform" -mindepth 1 -maxdepth 2 -type d 2>/dev/null | grep -v -E "$ignore_dir"
        find "$HOME/.ghq/gitlab.tools.pttep.com/digital-workspace-platform" -mindepth 1 -maxdepth 2 -type d 2>/dev/null | grep -v -E "$ignore_dir"
        find "$HOME/.ghq/gitlab.tools.pttep.com/aws-digital-platform" -mindepth 1 -maxdepth 2 -type d 2>/dev/null | grep -v -E "$ignore_dir"
        find "$HOME/.ghq/gitlab.tools.pttep.com/devsecops" -mindepth 1 -maxdepth 2 -type d 2>/dev/null | grep -v -E "$ignore_dir"
        # current dir immediate subdirs, already absolute (same wildcard fix as above)
        find -L "$PWD" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null | grep -v -E $ignore_dir
    end | sed -e 's/\/$//' | awk '!a[$0]++' | _fzf_change_directory $argv
end
