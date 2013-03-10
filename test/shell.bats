#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${NODENV_TEST_DIR}/myproject"
  cd "${NODENV_TEST_DIR}/myproject"
  echo "1.2.3" > .ruby-version
  NODENV_VERSION="" run nodenv-sh-shell
  assert_failure "nodenv: no shell-specific version configured"
}

@test "shell version" {
  NODENV_VERSION="1.2.3" run nodenv-sh-shell
  assert_success 'echo "$NODENV_VERSION"'
}

@test "shell unset" {
  run nodenv-sh-shell --unset
  assert_success "unset NODENV_VERSION"
}

@test "shell change invalid version" {
  run nodenv-sh-shell 1.2.3
  assert_failure
  assert_line "nodenv: version \`1.2.3' not installed"
  assert_line "return 1"
}

@test "shell change version" {
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  run nodenv-sh-shell 1.2.3
  assert_success 'export NODENV_VERSION="1.2.3"'
  refute_line "return 1"
}
