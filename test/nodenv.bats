#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run nodenv
  assert_success
  assert [ "${lines[0]}" = "nodenv 0.4.0" ]
}

@test "invalid command" {
  run nodenv does-not-exist
  assert_failure
  assert_output "nodenv: no such command \`does-not-exist'"
}

@test "default NODENV_ROOT" {
  NODENV_ROOT="" HOME=/home/mislav run nodenv root
  assert_success
  assert_output "/home/mislav/.nodenv"
}

@test "inherited NODENV_ROOT" {
  NODENV_ROOT=/opt/nodenv run nodenv root
  assert_success
  assert_output "/opt/nodenv"
}

@test "default NODENV_DIR" {
  run nodenv echo NODENV_DIR
  assert_output "$(pwd)"
}

@test "inherited NODENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  NODENV_DIR="$dir" run nodenv echo NODENV_DIR
  assert_output "$dir"
}

@test "invalid NODENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  NODENV_DIR="$dir" run nodenv echo NODENV_DIR
  assert_failure
  assert_output "nodenv: cannot change working directory to \`$dir'"
}
