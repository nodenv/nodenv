#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run nodenv-hooks
  assert_failure "Usage: nodenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${NODENV_TEST_DIR}/nodenv.d"
  path2="${NODENV_TEST_DIR}/etc/nodenv_hooks"
  NODENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  NODENV_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

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
  NODENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  NODENV_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  NODENV_HOOK_PATH="$path1:$path2" run nodenv-hooks exec
  assert_success
  assert_output <<OUT
${NODENV_TEST_DIR}/my hooks/nodenv.d/exec/hello.bash
${NODENV_TEST_DIR}/etc/nodenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  NODENV_HOOK_PATH="${NODENV_TEST_DIR}/nodenv.d"
  create_hook exec "hello.bash"
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
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  NODENV_HOOK_PATH="$path" run nodenv-hooks exec
  assert_success
  assert_output <<OUT
${HOME}/hola.bash
${NODENV_TEST_DIR}/nodenv.d/exec/bright.sh
OUT
}
