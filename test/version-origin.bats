#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${NODENV_ROOT}/version" ]
  run nodenv-version-origin
  assert_success "${NODENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$NODENV_ROOT"
  touch "${NODENV_ROOT}/version"
  run nodenv-version-origin
  assert_success "${NODENV_ROOT}/version"
}

@test "detects NODENV_VERSION" {
  NODENV_VERSION=1 run nodenv-version-origin
  assert_success "NODENV_VERSION environment variable"
}

@test "detects local file" {
  touch .node-version
  run nodenv-version-origin
  assert_success "${PWD}/.node-version"
}

@test "reports from hook" {
  mkdir -p "${NODENV_ROOT}/nodenv.d/version-origin"
  cat > "${NODENV_ROOT}/nodenv.d/version-origin/test.bash" <<HOOK
NODENV_VERSION_ORIGIN=plugin
HOOK

  NODENV_VERSION=1 NODENV_HOOK_PATH="${NODENV_ROOT}/nodenv.d" run nodenv-version-origin
  assert_success "plugin"
}

@test "doesn't inherit NODENV_VERSION_ORIGIN from environment" {
  NODENV_VERSION_ORIGIN=ignored run nodenv-version-origin
  assert_success "${NODENV_ROOT}/version"
}
