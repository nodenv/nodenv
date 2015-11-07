#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"

  mkdir -p "${NODENV_TEST_DIR}/bin"
  cat > "${NODENV_TEST_DIR}/bin/git" <<CMD
#!$BASH
if [[ \$1 == remote && \$PWD != "\$NODENV_TEST_DIR"/* ]]; then
  echo "not allowed" >&2
  exit 1
else
  exec $(which git) "\$@"
fi
CMD
  chmod +x "${NODENV_TEST_DIR}/bin/git"
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

@test "doesn't read version from non-nodenv repo" {
  mkdir -p "$NODENV_ROOT"
  cd "$NODENV_ROOT"
  git init
  git remote add origin https://github.com/homebrew/homebrew.git
  git_commit
  git tag v1.0

  cd "$NODENV_TEST_DIR"
  run nodenv---version
  assert_success
  [[ $output == "nodenv 0."* ]]
}

@test "reads version from git repo" {
  mkdir -p "$NODENV_ROOT"
  cd "$NODENV_ROOT"
  git init
  git remote add origin https://github.com/OiNutter/nodenv.git
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
  git remote add origin https://github.com/OiNutter/nodenv.git
  git_commit

  cd "$NODENV_TEST_DIR"
  run nodenv---version
  [[ $output == "nodenv 0."* ]]
}
