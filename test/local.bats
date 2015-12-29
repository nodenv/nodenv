#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${NODENV_TEST_DIR}/myproject"
  cd "${NODENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.node-version" ]
  run nodenv-local
  assert_failure "nodenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .node-version
  run nodenv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .node-version
  mkdir -p "subdir" && cd "subdir"
  run nodenv-local
  assert_success "1.2.3"
}

@test "ignores NODENV_DIR" {
  echo "1.2.3" > .node-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.node-version"
  NODENV_DIR="$HOME" run nodenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  run nodenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .node-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .node-version
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  run nodenv-local
  assert_success "1.0-pre"
  run nodenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .node-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .node-version
  run nodenv-local --unset
  assert_success ""
  refute [ -e .node-version ]
}
