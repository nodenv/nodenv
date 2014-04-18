function __fish_nodenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'nodenv' ]
    return 0
  end
  return 1
end

function __fish_nodenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c nodenv -n '__fish_nodenv_needs_command' -a '(nodenv commands)'
for cmd in (nodenv commands)
  complete -f -c nodenv -n "__fish_nodenv_using_command $cmd" -a "(nodenv completions $cmd)"
end
