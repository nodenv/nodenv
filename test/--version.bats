#!/usr/bin/env bats

load test_helper

export GIT_DIR="${NODENV_TEST_DIR}/.git"

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
  cd "$NODENV_TEST_DIR"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "default version" {
  assert [ ! -e "$NODENV_ROOT" ]
  run nodenv---version
  assert_success
  [[ $output == "nodenv "?.?.? ]]
}

@test "doesn't read version from non-nodenv repo" {
  git init
  git remote add origin https://github.com/homebrew/homebrew.git
  git_commit
  git tag v1.0

  run nodenv---version
  assert_success
  [[ $output == "nodenv "?.?.? ]]
}

@test "reads version from git repo" {
  git init
  git remote add origin https://github.com/nodenv/nodenv.git
  git_commit
  git tag v0.4.1
  git_commit
  git_commit

  run nodenv---version
  assert_success "nodenv 0.4.1-2-g$(git rev-parse --short HEAD)"
}

@test "prints default version if no tags in git repo" {
  git init
  git remote add origin https://github.com/nodenv/nodenv.git
  git_commit

  run nodenv---version
  [[ $output == "nodenv "?.?.? ]]
}
