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

@test "detects global 'version' file" {
  create_file "${NODENV_ROOT}/version"
  run nodenv-version-file
  assert_success "${NODENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  refute [ -e "${NODENV_ROOT}/version" ]
  refute [ -e ".node-version" ]
  run nodenv-version-file
  assert_success "${NODENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".node-version"
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

@test "finds version file in target directory" {
  create_file "project/.node-version"
  run nodenv-version-file "${PWD}/project"
  assert_success "${NODENV_TEST_DIR}/project/.node-version"
}

@test "fails when no version file in target directory" {
  run nodenv-version-file "$PWD"
  assert_failure ""
}
