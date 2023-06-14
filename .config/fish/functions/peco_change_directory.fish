function _peco_change_directory
  if [ (count $argv) ]
    peco --layout=bottom-up --query "$argv "|perl -pe 's/([ ()])/\\\\$1/g'|read foo
  else
    peco --layout=bottom-up |perl -pe 's/([ ()])/\\\\$1/g'|read foo
  end
  if [ $foo ]
    builtin cd $foo
    commandline -r ''
    commandline -f repaint
  else
    commandline ''
  end
end

function peco_change_directory
  begin
    set ignore_dir '\.git|\.terragrunt-cache|node_modules'
    echo $HOME/.config
    ghq list -p
    ls -ad */|perl -pe "s#^#$PWD/#"|grep -v -E $ignore_dir
    find $HOME/ghq/** -maxdepth 1 -type d|grep -v -E $ignore_dir
    find $HOME/pttep/** -maxdepth 1 -type d|grep -v -E $ignore_dir
  end | sed -e 's/\/$//' | awk '!a[$0]++' | _peco_change_directory $argv
end
