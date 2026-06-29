#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${NODENV_ROOT}/versions/$1/bin"
}

setup() {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${NODENV_ROOT}/versions" ]
  run nodenv-version-name
  assert_success
  assert_output "system"
}

@test "system version is not checked for existence" {
  NODENV_VERSION=system run nodenv-version-name
  assert_success
  assert_output "system"
}

@test "NODENV_VERSION can be overridden by hook" {
  create_version "1.8.7"
  create_version "1.9.3"
  create_hook version-name test.bash <<<"NODENV_VERSION=1.9.3"

  NODENV_VERSION=1.8.7 run nodenv-version-name
  assert_success
  assert_output "1.9.3"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export NODENV_VERSION=system
  IFS=$' \t\n' run nodenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "NODENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".node-version" <<<"1.8.7"
  run nodenv-version-name
  assert_success
  assert_output "1.8.7"

  NODENV_VERSION=1.9.3 run nodenv-version-name
  assert_success
  assert_output "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${NODENV_ROOT}/version" <<<"1.8.7"
  run nodenv-version-name
  assert_success
  assert_output "1.8.7"

  cat > ".node-version" <<<"1.9.3"
  run nodenv-version-name
  assert_success
  assert_output "1.9.3"
}

@test "missing version" {
  NODENV_VERSION=1.2 run nodenv-version-name
  assert_failure
  assert_output "nodenv: no installed version matches \`1.2' (set by NODENV_VERSION environment variable)"
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

@test "partial major version resolves to highest matching install" {
  create_version "26.0.0"
  create_version "26.3.1"
  create_version "26.10.0"
  create_version "27.0.0"
  cat > ".node-version" <<<"26"
  run nodenv-version-name
  assert_success
  assert_output "26.10.0"
}

@test "partial major version compares numerically not lexically" {
  create_version "26.9.0"
  create_version "26.10.0"
  cat > ".node-version" <<<"26"
  run nodenv-version-name
  assert_success
  assert_output "26.10.0"
}

@test "partial major version does not match across dot boundary" {
  create_version "260.0.0"
  NODENV_VERSION=26 run nodenv-version-name
  assert_failure
  assert_output "nodenv: no installed version matches \`26' (set by NODENV_VERSION environment variable)"
}

@test "partial major.minor version resolves to highest matching patch" {
  create_version "26.3.0"
  create_version "26.3.5"
  create_version "26.4.0"
  cat > ".node-version" <<<"26.3"
  run nodenv-version-name
  assert_success
  assert_output "26.3.5"
}

@test "partial version with 'v' prefix resolves to highest matching install" {
  create_version "26.3.1"
  cat > ".node-version" <<<"v26"
  run nodenv-version-name
  assert_success
  assert_output "26.3.1"
}

@test "exact version directory wins over partial match" {
  create_version "26"
  create_version "26.3.1"
  cat > ".node-version" <<<"26"
  run nodenv-version-name
  assert_success
  assert_output "26"
}

@test "partial version applies to NODENV_VERSION" {
  create_version "26.0.0"
  create_version "26.10.0"
  NODENV_VERSION=26 run nodenv-version-name
  assert_success
  assert_output "26.10.0"
}

@test "partial version with no matching install fails" {
  create_version "27.0.0"
  NODENV_VERSION=26 run nodenv-version-name
  assert_failure
  assert_output "nodenv: no installed version matches \`26' (set by NODENV_VERSION environment variable)"
}
