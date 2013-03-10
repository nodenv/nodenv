_nodenv() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(nodenv commands)" -- "$word") )
  else
    local command="${COMP_WORDS[1]}"
    local completions="$(nodenv completions "$command")"
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _nodenv nodenv
