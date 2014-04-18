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
  create_executable "2.0" "rspec"

  NODENV_VERSION=1.8 run nodenv-which node
  assert_success "${NODENV_ROOT}/versions/1.8/bin/node"

  NODENV_VERSION=2.0 run nodenv-which rspec
  assert_success "${NODENV_ROOT}/versions/2.0/bin/rspec"
}

@test "searches PATH for system version" {
  create_executable "${NODENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${NODENV_ROOT}/shims" "kill-all-humans"

  NODENV_VERSION=system run nodenv-which kill-all-humans
  assert_success "${NODENV_TEST_DIR}/bin/kill-all-humans"
}

@test "version not installed" {
  create_executable "2.0" "rspec"
  NODENV_VERSION=1.9 run nodenv-which rspec
  assert_failure "nodenv: version \`1.9' is not installed"
}

@test "no executable found" {
  create_executable "1.8" "rspec"
  NODENV_VERSION=1.8 run nodenv-which rake
  assert_failure "nodenv: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "1.8" "node"
  create_executable "1.9" "rspec"
  create_executable "2.0" "rspec"

  NODENV_VERSION=1.8 run nodenv-which rspec
  assert_failure
  assert_output <<OUT
nodenv: rspec: command not found

The \`rspec' command exists in these Node versions:
  1.9
  2.0
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${NODENV_TEST_DIR}/nodenv.d"
  mkdir -p "${hook_path}/which"
  cat > "${hook_path}/which/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  NODENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run nodenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}
