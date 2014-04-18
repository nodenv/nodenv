#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${NODENV_ROOT}/version" ]
  assert [ ! -e ".node-version" ]
  run nodenv-version-file
  assert_success "${NODENV_ROOT}/version"
}

@test "detects 'global' file" {
  create_file "${NODENV_ROOT}/global"
  run nodenv-version-file
  assert_success "${NODENV_ROOT}/global"
}

@test "detects 'default' file" {
  create_file "${NODENV_ROOT}/default"
  run nodenv-version-file
  assert_success "${NODENV_ROOT}/default"
}

@test "'version' has precedence over 'global' and 'default'" {
  create_file "${NODENV_ROOT}/version"
  create_file "${NODENV_ROOT}/global"
  create_file "${NODENV_ROOT}/default"
  run nodenv-version-file
  assert_success "${NODENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".node-version"
  run nodenv-version-file
  assert_success "${NODENV_TEST_DIR}/.node-version"
}

@test "legacy file in current directory" {
  create_file ".nodenv-version"
  run nodenv-version-file
  assert_success "${NODENV_TEST_DIR}/.nodenv-version"
}

@test ".node-version has precedence over legacy file" {
  create_file ".node-version"
  create_file ".nodenv-version"
  run nodenv-version-file
  assert_success "${NODENV_TEST_DIR}/.node-version"
}

@test "in parent directory" {
  create_file ".node-version"
  mkdir -p project
  cd project
  run nodenv-version-file
  assert_success "${NODENV_TEST_DIR}/.node-version"
}

@test "topmost file has precedence" {
  create_file ".node-version"
  create_file "project/.node-version"
  cd project
  run nodenv-version-file
  assert_success "${NODENV_TEST_DIR}/project/.node-version"
}

@test "legacy file has precedence if higher" {
  create_file ".node-version"
  create_file "project/.nodenv-version"
  cd project
  run nodenv-version-file
  assert_success "${NODENV_TEST_DIR}/project/.nodenv-version"
}

@test "NODENV_DIR has precedence over PWD" {
  create_file "widget/.node-version"
  create_file "project/.node-version"
  cd project
  NODENV_DIR="${NODENV_TEST_DIR}/widget" run nodenv-version-file
  assert_success "${NODENV_TEST_DIR}/widget/.node-version"
}

@test "PWD is searched if NODENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.node-version"
  cd project
  NODENV_DIR="${NODENV_TEST_DIR}/widget/blank" run nodenv-version-file
  assert_success "${NODENV_TEST_DIR}/project/.node-version"
}
