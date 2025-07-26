#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${NODENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "1.8" "node"
  create_executable "2.0" "npm"

  NODENV_VERSION=1.8 run nodenv-which node
  assert_success
  assert_output "${NODENV_ROOT}/versions/1.8/bin/node"

  NODENV_VERSION=2.0 run nodenv-which npm
  assert_success
  assert_output "${NODENV_ROOT}/versions/2.0/bin/npm"
}

@test "searches PATH for system version" {
  create_executable "${NODENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${NODENV_ROOT}/shims" "kill-all-humans"

  NODENV_VERSION=system run nodenv-which kill-all-humans
  assert_success
  assert_output "${NODENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${NODENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${NODENV_ROOT}/shims" "kill-all-humans"

  PATH="${NODENV_ROOT}/shims:$PATH" NODENV_VERSION=system run nodenv-which kill-all-humans
  assert_success
  assert_output "${NODENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${NODENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${NODENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${NODENV_ROOT}/shims" NODENV_VERSION=system run nodenv-which kill-all-humans
  assert_success
  assert_output "${NODENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${NODENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${NODENV_ROOT}/shims" "kill-all-humans"

  PATH="${NODENV_ROOT}/shims:${NODENV_ROOT}/shims:/tmp/non-existent:$PATH:${NODENV_ROOT}/shims" \
    NODENV_VERSION=system run nodenv-which kill-all-humans
  assert_success
  assert_output "${NODENV_TEST_DIR}/bin/kill-all-humans"
}

@test "doesn't include current directory in PATH search" {
  bats_require_minimum_version 1.5.0
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  PATH="$(path_without "kill-all-humans")" NODENV_VERSION=system run -127 nodenv-which kill-all-humans
  assert_failure
  assert_output "nodenv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "2.0" "npm"
  NODENV_VERSION=1.9 run nodenv-which npm
  assert_failure
  assert_output "nodenv: version \`1.9' is not installed (set by NODENV_VERSION environment variable)"
}

@test "no executable found" {
  bats_require_minimum_version 1.5.0
  create_executable "1.8" "npm"
  NODENV_VERSION=1.8 run -127 nodenv-which node
  assert_failure
  assert_output "nodenv: node: command not found"
}

@test "no executable found for system version" {
  bats_require_minimum_version 1.5.0
  PATH="$(path_without "mocha")" NODENV_VERSION=system run -127 nodenv-which mocha
  assert_failure
  assert_output "nodenv: mocha: command not found"
}

@test "executable found in other versions" {
  bats_require_minimum_version 1.5.0
  create_executable "1.8" "node"
  create_executable "1.9" "npm"
  create_executable "2.0" "npm"

  NODENV_VERSION=1.8 run -127 nodenv-which npm
  assert_failure
  assert_output - <<OUT
nodenv: npm: command not found

The \`npm' command exists in these Node versions:
  1.9
  2.0
OUT
}

# @test "executable not found in user gems" {
#   bats_require_minimum_version 1.5.0
#   create_executable "2.7.6" "ruby"
#   create_executable "${HOME}/.gem/ruby/2.7.0/bin" "rake"
#   GEM_HOME='' RBENV_VERSION=2.7.6 run -127 rbenv-which rake
#   assert_failure
# }
#
# @test "executable found in gem home" {
#   create_executable "2.7.6" "ruby"
#   create_executable "${HOME}/mygems/bin" "rake"
#   create_executable "${HOME}/.gem/ruby/2.7.0/bin" "rake"
#   GEM_HOME="${HOME}/mygems" RBENV_VERSION=2.7.6 run rbenv-which rake
#   assert_success "${HOME}/mygems/bin/rake"
# }
#
# @test "executable found in gem home (system ruby)" {
#   create_executable "${HOME}/mygems/bin" "rbenv-test-lolcat"
#   create_executable "${HOME}/.gem/ruby/2.6.0/bin" "rbenv-test-lolcat"
#   GEM_HOME="${HOME}/mygems" RBENV_VERSION=system run rbenv-which rbenv-test-lolcat
#   assert_success "${HOME}/mygems/bin/rbenv-test-lolcat"
# }

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' NODENV_VERSION=system run nodenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from nodenv-version-name" {
  mkdir -p "$NODENV_ROOT"
  cat > "${NODENV_ROOT}/version" <<<"1.8"
  create_executable "1.8" "node"

  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"

  NODENV_VERSION='' run nodenv-which node
  assert_success
  assert_output "${NODENV_ROOT}/versions/1.8/bin/node"
}
