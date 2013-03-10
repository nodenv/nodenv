if [[ ! -o interactive ]]; then
    return
fi

compctl -K _nodenv nodenv

_nodenv() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(nodenv commands)"
  else
    completions="$(nodenv completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
