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
  create_hook version-origin test.bash <<<"NODENV_VERSION_ORIGIN=plugin"

  NODENV_VERSION=1 run nodenv-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export NODENV_VERSION=system
  IFS=$' \t\n' run nodenv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit NODENV_VERSION_ORIGIN from environment" {
  NODENV_VERSION_ORIGIN=ignored run nodenv-version-origin
  assert_success "${NODENV_ROOT}/version"
}
