#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${NODENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${NODENV_ROOT}/shims" ]
  run nodenv-rehash
  assert_success ""
  assert [ -d "${NODENV_ROOT}/shims" ]
  rmdir "${NODENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${NODENV_ROOT}/shims"
  chmod -w "${NODENV_ROOT}/shims"
  run nodenv-rehash
  assert_failure "nodenv: cannot rehash: ${NODENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${NODENV_ROOT}/shims"
  touch "${NODENV_ROOT}/shims/.nodenv-shim"
  run nodenv-rehash
  assert_failure "nodenv: cannot rehash: ${NODENV_ROOT}/shims/.nodenv-shim exists"
}

@test "creates shims" {
  create_executable "0.10.26" "node"
  create_executable "0.10.26" "npm"
  create_executable "0.11.11" "node"
  create_executable "0.11.11" "npm"

  assert [ ! -e "${NODENV_ROOT}/shims/node" ]
  assert [ ! -e "${NODENV_ROOT}/shims/npm" ]

  run nodenv-rehash
  assert_success ""

  run ls "${NODENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
node
npm
OUT
}

@test "removes stale shims" {
  mkdir -p "${NODENV_ROOT}/shims"
  touch "${NODENV_ROOT}/shims/oldshim1"
  chmod +x "${NODENV_ROOT}/shims/oldshim1"

  create_executable "2.0" "npm"
  create_executable "2.0" "node"

  run nodenv-rehash
  assert_success ""

  assert [ ! -e "${NODENV_ROOT}/shims/oldshim1" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "node"
  create_executable "dirname2 preview1" "npm"

  assert [ ! -e "${NODENV_ROOT}/shims/node" ]
  assert [ ! -e "${NODENV_ROOT}/shims/npm" ]

  run nodenv-rehash
  assert_success ""

  run ls "${NODENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
node
npm
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${NODENV_TEST_DIR}/nodenv.d"
  mkdir -p "${hook_path}/rehash"
  cat > "${hook_path}/rehash/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  NODENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run nodenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "2.0" "node"
  NODENV_SHELL=bash run nodenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${NODENV_ROOT}/shims/node" ]
}

@test "sh-rehash in fish" {
  create_executable "2.0" "node"
  NODENV_SHELL=fish run nodenv-sh-rehash
  assert_success ""
  assert [ -x "${NODENV_ROOT}/shims/node" ]
}
