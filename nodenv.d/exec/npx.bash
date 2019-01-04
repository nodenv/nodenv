# If npx is being executed, remove nodenv's shims from PATH
# such that npx won't find the shims for executables that
# only exist in non-active nodes.
# This ensures npx can install the necessary package on-demand.

[ "$NODENV_COMMAND" = npx ] || return 0

remove_from_path() {
  local path_to_remove="$1"
  local path_before
  local result=":${PATH//\~/$HOME}:"
  while [ "$path_before" != "$result" ]; do
    path_before="$result"
    result="${result//:$path_to_remove:/:}"
  done
  result="${result%:}"
  echo "${result#:}"
}

PATH="$(remove_from_path "${NODENV_ROOT}/shims")"
export PATH
