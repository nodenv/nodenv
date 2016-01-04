#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run nodenv
  assert_failure
  assert_line 0 "$(nodenv---version)"
}

@test "invalid command" {
  run nodenv does-not-exist
  assert_failure
  assert_output "nodenv: no such command \`does-not-exist'"
}

@test "default NODENV_ROOT" {
  NODENV_ROOT="" HOME=/home/will run nodenv root
  assert_success
  assert_output "/home/will/.nodenv"
}

@test "inherited NODENV_ROOT" {
  NODENV_ROOT=/opt/nodenv run nodenv root
  assert_success
  assert_output "/opt/nodenv"
}

@test "default NODENV_DIR" {
  run nodenv echo NODENV_DIR
  assert_output "$(pwd)"
}

@test "inherited NODENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  NODENV_DIR="$dir" run nodenv echo NODENV_DIR
  assert_output "$dir"
}

@test "invalid NODENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  NODENV_DIR="$dir" run nodenv echo NODENV_DIR
  assert_failure
  assert_output "nodenv: cannot change working directory to \`$dir'"
}

@test "adds its own libexec to PATH" {
  run nodenv echo "PATH"
  assert_success "${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$NODENV_ROOT"/plugins/node-build/bin
  mkdir -p "$NODENV_ROOT"/plugins/nodenv-each/bin
  run nodenv echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${NODENV_ROOT}/plugins/nodenv-each/bin"
  assert_line 2 "${NODENV_ROOT}/plugins/node-build/bin"
}

@test "NODENV_HOOK_PATH preserves value from environment" {
  NODENV_HOOK_PATH=/my/hook/path:/other/hooks run nodenv echo -F: "NODENV_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${NODENV_ROOT}/nodenv.d"
}

@test "NODENV_HOOK_PATH includes nodenv built-in plugins" {
  unset NODENV_HOOK_PATH
  run nodenv echo "NODENV_HOOK_PATH"
  assert_success "${NODENV_ROOT}/nodenv.d:${BATS_TEST_DIRNAME%/*}/nodenv.d:/usr/local/etc/nodenv.d:/etc/nodenv.d:/usr/lib/nodenv/hooks"
}
