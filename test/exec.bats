#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${NODENV_ROOT}/versions/${NODENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export NODENV_VERSION="2.0"
  run nodenv-exec node -v
  assert_failure "nodenv: version \`2.0' is not installed (set by NODENV_VERSION environment variable)"
}

@test "fails with invalid version set from file" {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
  echo 1.9 > .node-version
  run nodenv-exec npm
  assert_failure "nodenv: version \`1.9' is not installed (set by $PWD/.node-version)"
}

@test "completes with names of executables" {
  export NODENV_VERSION="2.0"
  create_executable "node" "#!/bin/sh"
  create_executable "npm" "#!/bin/sh"

  nodenv-rehash
  run nodenv-completions exec
  assert_success
  assert_output <<OUT
--help
node
npm
OUT
}

@test "carries original IFS within hooks" {
  create_hook exec hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export NODENV_VERSION=system
  IFS=$' \t\n' run nodenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export NODENV_VERSION="2.0"
  create_executable "node" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run nodenv-exec node -w "/path to/node script.rb" -- extra args
  assert_success
  assert_output <<OUT
${NODENV_ROOT}/versions/2.0/bin/node
  -w
  /path to/node script.rb
  --
  extra
  args
OUT
}

@test "supports node -S <cmd>" {
  export NODENV_VERSION="2.0"

  # emulate `node -S' behavior
  create_executable "node" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${NODEPATH:-\$PATH}" which \$2)"
  # assert that the found executable has node for shebang
  if head -1 "\$found" | grep node >/dev/null; then
    \$BASH "\$found"
  else
    echo "node: no Node script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'node 2.0 (nodenv test)'
fi
SH

  create_executable "npm" <<SH
#!/usr/bin/env node
echo hello npm
SH

  nodenv-rehash
  run node -S npm
  assert_success "hello npm"
}
