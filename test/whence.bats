#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${NODENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "finds versions where present" {
  create_executable "1.8" "node"
  create_executable "1.8" "npm"
  create_executable "2.0" "node"

  run nodenv-whence node
  assert_success
  assert_output <<OUT
1.8
2.0
OUT

  run nodenv-whence npm
  assert_success "1.8"

}
