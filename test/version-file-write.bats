#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run nodenv-version-file-write
  assert_failure
  assert_output "Usage: nodenv version-file-write <file> <version>"
  run nodenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".node-version" ]
  run nodenv-version-file-write ".node-version" "1.8.7"
  assert_failure
  assert_output "nodenv: no installed version matches \`1.8.7'"
  assert [ ! -e ".node-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${NODENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run nodenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success
  refute_output
  assert [ "$(cat my-version)" = "1.8.7" ]
}

@test "writes a partial version that matches an install" {
  mkdir -p "${NODENV_ROOT}/versions/26.3.1/bin"
  assert [ ! -e "my-version" ]
  run nodenv-version-file-write "${PWD}/my-version" "26"
  assert_success
  refute_output
  assert [ "$(cat my-version)" = "26" ]
}

@test "setting partial version with no match fails" {
  mkdir -p "${NODENV_ROOT}/versions/27.0.0/bin"
  run nodenv-version-file-write ".node-version" "26"
  assert_failure
  assert_output "nodenv: no installed version matches \`26'"
  assert [ ! -e ".node-version" ]
}
