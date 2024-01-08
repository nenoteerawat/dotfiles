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
        find $(ghq root) -maxdepth 4 -type d -name .git | sed 's/\/\.git//'
        find $HOME/.ghq/gitlab.tools.pttep.com/digital-workspace-platform/delorean-infrastructure/iac/* -maxdepth 1 -type d | grep -v -E $ignore_dir
        find $HOME/.ghq/gitlab.tools.pttep.com/digital-workspace-platform/delorean-platform/* -maxdepth 1 -type d | grep -v -E $ignore_dir
        ls -ad */ | perl -pe "s#^#$PWD/#" | grep -v -E $ignore_dir
    end | sed -e 's/\/$//' | awk '!a[$0]++' | _fzf_change_directory $argv
end
