#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "default version" {
  assert [ ! -e "$NODENV_ROOT" ]
  run nodenv---version
  assert_success
  [[ $output == "nodenv 0."* ]]
}

@test "reads version from git repo" {
  mkdir -p "$NODENV_ROOT"
  cd "$NODENV_ROOT"
  git init
  git_commit
  git tag v0.4.1
  git_commit
  git_commit

  cd "$NODENV_TEST_DIR"
  run nodenv---version
  assert_success
  [[ $output == "nodenv 0.4.1-2-g"* ]]
}

@test "prints default version if no tags in git repo" {
  mkdir -p "$NODENV_ROOT"
  cd "$NODENV_ROOT"
  git init
  git_commit

  cd "$NODENV_TEST_DIR"
  run nodenv---version
  [[ $output == "nodenv 0."* ]]
}
