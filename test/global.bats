#!/usr/bin/env bats

load test_helper

@test "default" {
  run nodenv-global
  assert_success
  assert_output "system"
}

@test "read NODENV_ROOT/version" {
  mkdir -p "$NODENV_ROOT"
  echo "1.2.3" > "$NODENV_ROOT/version"
  run nodenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set NODENV_ROOT/version" {
  mkdir -p "$NODENV_ROOT/versions/1.2.3"
  run nodenv-global "1.2.3"
  assert_success
  run nodenv-global
  assert_success "1.2.3"
}

@test "fail setting invalid NODENV_ROOT/version" {
  mkdir -p "$NODENV_ROOT"
  run nodenv-global "1.2.3"
  assert_failure "nodenv: version \`1.2.3' not installed"
}

@test "unset (remove) NODENV_ROOT/version" {
  mkdir -p "$NODENV_ROOT"
  echo "1.2.3" > "$NODENV_ROOT/version"

  run nodenv-global --unset
  assert_success

  refute [ -e $NODENV_ROOT/version ]
  run nodenv-global
  assert_output "system"
}
