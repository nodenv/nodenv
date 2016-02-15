#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${NODENV_TEST_DIR}/myproject"
  cd "${NODENV_TEST_DIR}/myproject"
  echo "1.2.3" > .node-version
  NODENV_VERSION="" run nodenv-sh-shell
  assert_failure
  assert_output "nodenv: no shell-specific version configured"
}

@test "shell version" {
  NODENV_SHELL=bash NODENV_VERSION="1.2.3" run nodenv-sh-shell
  assert_success
  assert_output 'echo "$NODENV_VERSION"'
}

@test "shell version (fish)" {
  NODENV_SHELL=fish NODENV_VERSION="1.2.3" run nodenv-sh-shell
  assert_success
  assert_output 'echo "$NODENV_VERSION"'
}

@test "shell unset" {
  NODENV_SHELL=bash run nodenv-sh-shell --unset
  assert_success
  assert_output "unset NODENV_VERSION"
}

@test "shell unset (fish)" {
  NODENV_SHELL=fish run nodenv-sh-shell --unset
  assert_success
  assert_output "set -e NODENV_VERSION"
}

@test "shell change invalid version" {
  run nodenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
nodenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  NODENV_SHELL=bash run nodenv-sh-shell 1.2.3
  assert_success
  assert_output 'export NODENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  NODENV_SHELL=fish run nodenv-sh-shell 1.2.3
  assert_success
  assert_output 'setenv NODENV_VERSION "1.2.3"'
}
