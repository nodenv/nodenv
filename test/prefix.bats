#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${NODENV_TEST_DIR}/myproject"
  cd "${NODENV_TEST_DIR}/myproject"
  echo "1.2.3" > .node-version
  mkdir -p "${NODENV_ROOT}/versions/1.2.3"
  run nodenv-prefix
  assert_success "${NODENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  NODENV_VERSION="1.2.3" run nodenv-prefix
  assert_failure "nodenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${NODENV_TEST_DIR}/bin"
  touch "${NODENV_TEST_DIR}/bin/node"
  chmod +x "${NODENV_TEST_DIR}/bin/node"
  NODENV_VERSION="system" run nodenv-prefix
  assert_success "$NODENV_TEST_DIR"
}
