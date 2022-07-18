function peco_select_z_history
  z -l | peco --query "$argv" | awk '{ print $2 }' | read foo

  if [ $foo ]
    cd $foo
  end

  commandline -f repaint
end
