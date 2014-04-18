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

@test "supports legacy .nodenv-version file" {
  echo "1.2.3" > .nodenv-version
  run nodenv-local
  assert_success "1.2.3"
}

@test "local .node-version has precedence over .nodenv-version" {
  echo "1.8" > .nodenv-version
  echo "2.0" > .node-version
  run nodenv-local
  assert_success "2.0"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .node-version
  mkdir -p "subdir" && cd "subdir"
  run nodenv-local
  assert_failure
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

@test "renames .nodenv-version to .node-version" {
  echo "1.8.7" > .nodenv-version
  mkdir -p "${NODENV_ROOT}/versions/1.9.3"
  run nodenv-local
  assert_success "1.8.7"
  run nodenv-local "1.9.3"
  assert_success
  assert_output <<OUT
nodenv: removed existing \`.nodenv-version' file and migrated
       local version specification to \`.node-version' file
OUT
  assert [ ! -e .nodenv-version ]
  assert [ "$(cat .node-version)" = "1.9.3" ]
}

@test "doesn't rename .nodenv-version if changing the version failed" {
  echo "1.8.7" > .nodenv-version
  assert [ ! -e "${NODENV_ROOT}/versions/1.9.3" ]
  run nodenv-local "1.9.3"
  assert_failure "nodenv: version \`1.9.3' not installed"
  assert [ ! -e .node-version ]
  assert [ "$(cat .nodenv-version)" = "1.8.7" ]
}

@test "unsets local version" {
  touch .node-version
  run nodenv-local --unset
  assert_success ""
  assert [ ! -e .nodenv-version ]
}

@test "unsets alternate version file" {
  touch .nodenv-version
  run nodenv-local --unset
  assert_success ""
  assert [ ! -e .nodenv-version ]
}
