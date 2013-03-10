#!/usr/bin/env bats

load test_helper

@test "empty rehash" {
  assert [ ! -d "${NODENV_ROOT}/shims" ]
  run nodenv-rehash
  assert_success
  assert [ -d "${NODENV_ROOT}/shims" ]
  rmdir "${NODENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${NODENV_ROOT}/shims"
  chmod -w "${NODENV_ROOT}/shims"
  run nodenv-rehash
  assert_failure
  assert_output "nodenv: cannot rehash: ${NODENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${NODENV_ROOT}/shims"
  touch "${NODENV_ROOT}/shims/.nodenv-shim"
  run nodenv-rehash
  assert_failure
  assert_output "nodenv: cannot rehash: ${NODENV_ROOT}/shims/.nodenv-shim exists"
}
