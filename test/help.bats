#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run nodenv-help
  assert_success
  assert_line "Usage: nodenv <command> [<args>]"
  assert_line "Some useful nodenv commands are:"
}

@test "invalid command" {
  run nodenv-help hello
  assert_failure "nodenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${NODENV_TEST_DIR}/bin"
  cat > "${NODENV_TEST_DIR}/bin/nodenv-hello" <<SH
#!shebang
# Usage: nodenv hello <world>
# Summary: Says "hello" to you, from nodenv
# This command is useful for saying hello.
echo hello
SH

  run nodenv-help hello
  assert_success
  assert_output <<SH
Usage: nodenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${NODENV_TEST_DIR}/bin"
  cat > "${NODENV_TEST_DIR}/bin/nodenv-hello" <<SH
#!shebang
# Usage: nodenv hello <world>
# Summary: Says "hello" to you, from nodenv
echo hello
SH

  run nodenv-help hello
  assert_success
  assert_output <<SH
Usage: nodenv hello <world>

Says "hello" to you, from nodenv
SH
}

@test "extracts only usage" {
  mkdir -p "${NODENV_TEST_DIR}/bin"
  cat > "${NODENV_TEST_DIR}/bin/nodenv-hello" <<SH
#!shebang
# Usage: nodenv hello <world>
# Summary: Says "hello" to you, from nodenv
# This extended help won't be shown.
echo hello
SH

  run nodenv-help --usage hello
  assert_success "Usage: nodenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${NODENV_TEST_DIR}/bin"
  cat > "${NODENV_TEST_DIR}/bin/nodenv-hello" <<SH
#!shebang
# Usage: nodenv hello <world>
#        nodenv hi [everybody]
#        nodenv hola --translate
# Summary: Says "hello" to you, from nodenv
# Help text.
echo hello
SH

  run nodenv-help hello
  assert_success
  assert_output <<SH
Usage: nodenv hello <world>
       nodenv hi [everybody]
       nodenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${NODENV_TEST_DIR}/bin"
  cat > "${NODENV_TEST_DIR}/bin/nodenv-hello" <<SH
#!shebang
# Usage: nodenv hello <world>
# Summary: Says "hello" to you, from nodenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run nodenv-help hello
  assert_success
  assert_output <<SH
Usage: nodenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
