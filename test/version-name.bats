#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${NODENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${NODENV_ROOT}/versions" ]
  run nodenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  NODENV_VERSION=system run nodenv-version-name
  assert_success "system"
}

@test "NODENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".node-version" <<<"1.8.7"
  run nodenv-version-name
  assert_success "1.8.7"

  NODENV_VERSION=1.9.3 run nodenv-version-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${NODENV_ROOT}/version" <<<"1.8.7"
  run nodenv-version-name
  assert_success "1.8.7"

  cat > ".node-version" <<<"1.9.3"
  run nodenv-version-name
  assert_success "1.9.3"
}

@test "missing version" {
  NODENV_VERSION=1.2 run nodenv-version-name
  assert_failure "nodenv: version \`1.2' is not installed (set by NODENV_VERSION environment variable)"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".node-version" <<<"node-1.8.7"
  run nodenv-version-name
  assert_success
  assert_output "1.8.7"
}

@test "version with 'v' prefix in name" {
  create_version "4.1.0"
  cat > ".node-version" <<<"v4.1.0"
  run nodenv-version-name
  assert_success
  assert_output "4.1.0"
}

@test "version with 'node-v' prefix in name" {
  create_version "4.1.0"
  cat > ".node-version" <<<"node-v4.1.0"
  run nodenv-version-name
  assert_success
  assert_output "4.1.0"
}

@test "iojs version with 'v' prefix in name" {
  create_version "iojs-3.1.0"
  cat > ".node-version" <<<"iojs-v3.1.0"
  run nodenv-version-name
  assert_success
  assert_output "iojs-3.1.0"
}
