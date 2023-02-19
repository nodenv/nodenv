#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${NODENV_ROOT}/versions/$1"
}

alias_version() {
  ln -sf "$NODENV_ROOT/versions/$2" "$NODENV_ROOT/versions/$1"
}

setup() {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${NODENV_ROOT}/versions" ]
  run nodenv-version
  assert_success
  assert_output "system"
}

@test "using a symlink/alias" {
  create_version 1.9.3
  alias_version 1.9 1.9.3

  NODENV_VERSION=1.9 run nodenv-version

  assert_success
  assert_output "1.9 => 1.9.3 (set by NODENV_VERSION environment variable)"
}

@test "links to links resolve the final target" {
  create_version 1.9.3
  alias_version 1.9 1.9.3
  alias_version 1 1.9

  NODENV_VERSION=1 run nodenv-version

  assert_success
  assert_output "1 => 1.9.3 (set by NODENV_VERSION environment variable)"
}

@test "set by NODENV_VERSION" {
  create_version "1.9.3"
  NODENV_VERSION=1.9.3 run nodenv-version
  assert_success
  assert_output "1.9.3 (set by NODENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "1.9.3"
  cat > ".node-version" <<<"1.9.3"
  run nodenv-version
  assert_success
  assert_output "1.9.3 (set by ${PWD}/.node-version)"
}

@test "set by global file" {
  create_version "1.9.3"
  cat > "${NODENV_ROOT}/version" <<<"1.9.3"
  run nodenv-version
  assert_success
  assert_output "1.9.3 (set by ${NODENV_ROOT}/version)"
}
