load ../node_modules/bats-assert/all

unset NODENV_VERSION
unset NODENV_DIR

# guard against executing this block twice due to bats internals
if [ -z "$NODENV_TEST_DIR" ]; then
  NODENV_TEST_DIR="${BATS_TMPDIR}/nodenv"
  export NODENV_TEST_DIR="$(mktemp -d "${NODENV_TEST_DIR}.XXX" 2>/dev/null || echo "$NODENV_TEST_DIR")"

  if enable -f "${BATS_TEST_DIRNAME}"/../libexec/nodenv-realpath.dylib realpath 2>/dev/null; then
    export NODENV_TEST_DIR="$(realpath "$NODENV_TEST_DIR")"
  else
    if [ -n "$NODENV_NATIVE_EXT" ]; then
      echo "nodenv: failed to load \`realpath' builtin" >&2
      exit 1
    fi
  fi

  export NODENV_ROOT="${NODENV_TEST_DIR}/root"
  export HOME="${NODENV_TEST_DIR}/home"
  export NODENV_HOOK_PATH="${NODENV_ROOT}/nodenv.d"

  PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
  PATH="${NODENV_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
  PATH="${NODENV_ROOT}/shims:$PATH"
  export PATH

  for xdg_var in `env 2>/dev/null | grep ^XDG_ | cut -d= -f1`; do unset "$xdg_var"; done
  unset xdg_var
fi

teardown() {
  rm -rf "$NODENV_TEST_DIR"
}

# Output a modified PATH that ensures that the given executable is not present,
# but in which system utils necessary for nodenv operation are still available.
path_without() {
  local exe="$1"
  local path=":${PATH}:"
  local found alt util
  for found in $(which -a "$exe"); do
    found="${found%/*}"
    if [ "$found" != "${NODENV_ROOT}/shims" ]; then
      alt="${NODENV_TEST_DIR}/$(echo "${found#/}" | tr '/' '-')"
      mkdir -p "$alt"
      for util in bash head cut readlink greadlink; do
        if [ -x "${found}/$util" ]; then
          ln -s "${found}/$util" "${alt}/$util"
        fi
      done
      path="${path/:${found}:/:${alt}:}"
    fi
  done
  path="${path#:}"
  echo "${path%:}"
}

create_hook() {
  mkdir -p "${NODENV_HOOK_PATH}/$1"
  touch "${NODENV_HOOK_PATH}/$1/$2"
  if [ ! -t 0 ]; then
    cat > "${NODENV_HOOK_PATH}/$1/$2"
  fi
}
