#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${NODENV_TEST_DIR}/myproject"
  cd "${NODENV_TEST_DIR}/myproject"
  echo "1.2.3" > .node-version
  NODENV_VERSION="" run nodenv-sh-shell
  assert_failure "nodenv: no shell-specific version configured"
}

@test "shell version" {
  NODENV_SHELL=bash NODENV_VERSION="1.2.3" run nodenv-sh-shell
  assert_success 'echo "$NODENV_VERSION"'
}

@test "shell version (fish)" {
  NODENV_SHELL=fish NODENV_VERSION="1.2.3" run nodenv-sh-shell
  assert_success 'echo "$NODENV_VERSION"'
}

@test "shell revert" {
  NODENV_SHELL=bash run nodenv-sh-shell -
  assert_success
  assert_line 0 'if [ -n "${NODENV_VERSION_OLD+x}" ]; then'
}

@test "shell revert (fish)" {
  NODENV_SHELL=fish run nodenv-sh-shell -
  assert_success
  assert_line 0 'if set -q NODENV_VERSION_OLD'
}

@test "shell unset" {
  NODENV_SHELL=bash run nodenv-sh-shell --unset
  assert_success
  assert_output <<OUT
NODENV_VERSION_OLD="\$NODENV_VERSION"
unset NODENV_VERSION
OUT
}

@test "shell unset (fish)" {
  NODENV_SHELL=fish run nodenv-sh-shell --unset
  assert_success
  assert_output <<OUT
set -gu NODENV_VERSION_OLD "\$NODENV_VERSION"
set -e NODENV_VERSION
OUT
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
  assert_output <<OUT
NODENV_VERSION_OLD="\$NODENV_VERSION"
export NODENV_VERSION="1.2.3"
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  NODENV_SHELL=fish run nodenv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
set -gu NODENV_VERSION_OLD "\$NODENV_VERSION"
set -gx NODENV_VERSION "1.2.3"
OUT
}
