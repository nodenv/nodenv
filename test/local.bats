#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${NODENV_TEST_DIR}/myproject"
  cd "${NODENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.ruby-version" ]
  run nodenv-local
  assert_failure "nodenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .ruby-version
  run nodenv-local
  assert_success "1.2.3"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .ruby-version
  mkdir -p "subdir" && cd "subdir"
  run nodenv-local
  assert_failure
}

@test "ignores NODENV_DIR" {
  echo "1.2.3" > .ruby-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.ruby-version"
  NODENV_DIR="$HOME" run nodenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  run nodenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .ruby-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .ruby-version
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  run nodenv-local
  assert_success "1.0-pre"
  run nodenv-local 1.2.3
  assert_success ""
  run nodenv-local
  assert_success "1.2.3"
}
