#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run nodenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${NODENV_ROOT}/shims"
  touch "${NODENV_ROOT}/shims/node"
  touch "${NODENV_ROOT}/shims/irb"
  run nodenv-shims
  assert_success
  assert_line "${NODENV_ROOT}/shims/node"
  assert_line "${NODENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${NODENV_ROOT}/shims"
  touch "${NODENV_ROOT}/shims/node"
  touch "${NODENV_ROOT}/shims/irb"
  run nodenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "node"
}
