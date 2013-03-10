if [[ ! -o interactive ]]; then
    return
fi

compctl -K _nodenv nodenv

_nodenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(nodenv commands)"
  else
    completions="$(nodenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
