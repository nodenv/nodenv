#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run nodenv-hooks
  assert_failure "Usage: nodenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${NODENV_TEST_DIR}/nodenv.d"
  path2="${NODENV_TEST_DIR}/etc/nodenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

  NODENV_HOOK_PATH="$path1:$path2" run nodenv-hooks exec
  assert_success
  assert_output <<OUT
${NODENV_TEST_DIR}/nodenv.d/exec/ahoy.bash
${NODENV_TEST_DIR}/nodenv.d/exec/hello.bash
${NODENV_TEST_DIR}/etc/nodenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${NODENV_TEST_DIR}/my hooks/nodenv.d"
  path2="${NODENV_TEST_DIR}/etc/nodenv hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path2" exec "ahoy.bash"

  NODENV_HOOK_PATH="$path1:$path2" run nodenv-hooks exec
  assert_success
  assert_output <<OUT
${NODENV_TEST_DIR}/my hooks/nodenv.d/exec/hello.bash
${NODENV_TEST_DIR}/etc/nodenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  path="${NODENV_TEST_DIR}/nodenv.d"
  create_hook "$path" exec "hello.bash"
  mkdir -p "$HOME"

  NODENV_HOOK_PATH="${HOME}/../nodenv.d" run nodenv-hooks exec
  assert_success "${NODENV_TEST_DIR}/nodenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${NODENV_TEST_DIR}/nodenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"

  NODENV_HOOK_PATH="$path" run nodenv-hooks exec
  assert_success "${HOME}/hola.bash"
}
