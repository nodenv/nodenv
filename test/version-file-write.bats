#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run nodenv-version-file-write
  assert_failure "Usage: nodenv version-file-write <file> <version>"
  run nodenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".node-version" ]
  run nodenv-version-file-write ".node-version" "1.8.7"
  assert_failure "nodenv: version \`1.8.7' not installed"
  assert [ ! -e ".node-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${NODENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run nodenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success ""
  assert [ "$(cat my-version)" = "1.8.7" ]
}
