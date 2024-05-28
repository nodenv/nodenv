load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load

unset NODENV_VERSION
unset NODENV_DIR

# guard against executing this block twice due to bats internals
if [ -z "$NODENV_TEST_DIR" ]; then
  NODENV_TEST_DIR="${BATS_TMPDIR}/nodenv"
  NODENV_TEST_DIR="$(mktemp -d "${NODENV_TEST_DIR}.XXX" 2>/dev/null || echo "$NODENV_TEST_DIR")"
  export NODENV_TEST_DIR

  NODENV_REALPATH=$BATS_TEST_DIRNAME/../libexec/nodenv-realpath.dylib

  if enable -f "$NODENV_REALPATH" realpath 2>/dev/null; then
    NODENV_TEST_DIR="$(realpath "$NODENV_TEST_DIR")"
  else
    if [ -x "$NODENV_REALPATH" ]; then
      echo "nodenv: failed to load \`realpath' builtin" >&2
      exit 1
    fi
  fi

  export NODENV_ROOT="${NODENV_TEST_DIR}/root"
  export HOME="${NODENV_TEST_DIR}/home"
  export NODENV_HOOK_PATH=$NODENV_ROOT/nodenv.d:$BATS_TEST_DIRNAME/../nodenv.d

  PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
  PATH="${NODENV_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
  PATH="${NODENV_ROOT}/shims:$PATH"
  export PATH

  for xdg_var in $(env 2>/dev/null | grep ^XDG_ | cut -d= -f1); do unset "$xdg_var"; done
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
  for found in $(type -aP "$exe"); do
    found="${found%/*}"
    if [ "$found" != "${NODENV_ROOT}/shims" ]; then
      alt="${NODENV_TEST_DIR}/$(echo "${found#/}" | tr '/' '-')"
      mkdir -p "$alt"
      for util in bash head cut readlink greadlink sed sort awk; do
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
  local hook_path=${NODENV_HOOK_PATH%%:*}
  mkdir -p "${hook_path:?}/$1"
  touch "${hook_path:?}/$1/$2"
  if [ ! -t 0 ]; then
    cat > "${hook_path:?}/$1/$2"
  fi
}
