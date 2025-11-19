# Seamlessly manage your app’s Node environment with nodenv

[![Tests](https://img.shields.io/github/actions/workflow/status/nodenv/nodenv/test.yml?label=tests&logo=github)](https://github.com/nodenv/nodenv/actions/workflows/test.yml)
[![Latest GitHub Release](https://img.shields.io/github/v/release/nodenv/nodenv?label=github&logo=github&sort=semver)](https://github.com/nodenv/nodenv/releases/latest)
[![Latest Homebrew Release](https://img.shields.io/homebrew/v/nodenv?logo=homebrew&logoColor=white)](https://formulae.brew.sh/formula/nodenv)
[![Latest npm Release](https://img.shields.io/npm/v/@nodenv/nodenv?logo=npm&logoColor=white)](https://www.npmjs.com/package/@nodenv/nodenv/v/latest)

nodenv is a version manager tool for the Node.js on Unix-like systems. It is
useful for switching between multiple Node.js versions on the same machine and
for ensuring that each project you are working on always runs on the correct
Node.js version.

## How It Works

After nodenv injects itself into your PATH at installation time, any invocation
of `node`, `npm`, `npx`, or other Node.js-related executable will first
activate nodenv. Then, nodenv scans the current project directory for a file
named `.node-version`. If found, that file determines the version of Node.js
that should be used within that directory. Finally, nodenv looks up that
Node.js version among those installed under `~/.nodenv/versions/`.

You can choose the Node.js version for your project with, for example:

```sh
cd myproject
# choose Node.js version 24.1.0:
nodenv local 24.1.0
```

Doing so will create or update the `.node-version` file in the current
directory with the version that you've chosen. A different project of yours
that is another directory might be using a different version of Node.js
altogether—nodenv will seamlessly transition from one Node.js version to
another when you switch projects.

Finally, almost every aspect of nodenv's mechanism is [customizable via
plugins][plugins] written in Bash.

The simplicity of nodenv has its benefits, but also some downsides. See the
[comparison of version managers][alternatives] for more details and some
alternatives.

## Installation

On systems with Homebrew package manager, the “Using Package Managers” method
is recommended. On other systems, “Basic Git Checkout” might be the easiest way
of ensuring that you are always installing the latest version of nodenv.

### Using Package Managers

1. Install nodenv using one of the following approaches.

   #### Homebrew

   On macOS or Linux, we recommend installing nodenv with [Homebrew](https://brew.sh).

   ```sh
   brew install nodenv
   ```

   #### Debian, Ubuntu, and their derivatives

   > [!CAUTION]
   > Presently, `nodenv` is not available in the Debian or Ubuntu package
   > repositories. To install the latest version, it is recommended to
   > [install nodenv using Git](#basic-git-checkout). [Consider
   > contributing!](https://github.com/nodenv/nodenv/issues/210)

   #### Arch Linux and its derivatives

   Archlinux has an [AUR Package](https://aur.archlinux.org/packages/nodenv/) for
   nodenv and you can install it from the AUR using the instructions from this
   [wiki page](https://wiki.archlinux.org/index.php/Arch_User_Repository#Installing_and_upgrading_packages).

   #### Fedora

   > [!CAUTION]
   > Presently, `nodenv` is not available in the Fedora package
   > repositories. To install the latest version, it is recommended to
   > [install nodenv using Git](#basic-git-checkout). [Consider
   > contributing!](https://github.com/nodenv/nodenv/issues/210)

   <!--
   Fedora has an [official package](https://packages.fedoraproject.org/pkgs/nodenv/nodenv/) which you can install:

   ```sh
   sudo dnf install nodenv
   ```
   -->

2. Set up your shell to load nodenv.

   ```sh
   nodenv init
   ```

3. Close your Terminal window and open a new one so your changes take effect.

That's it! You are now ready to [install some Node.js versions](#installing-node-versions).

### Basic Git Checkout

> [!NOTE]
> For a more automated install, you can use [nodenv-installer][]. If you do not want to execute scripts downloaded from a web URL or simply prefer a manual approach, follow the steps below.

This will get you going with the latest version of nodenv without needing a system-wide install.

1. Clone nodenv into `~/.nodenv`.

   ```sh
   git clone https://github.com/nodenv/nodenv.git ~/.nodenv
   ```

2. Set up your shell to load nodenv.

   ```sh
   ~/.nodenv/bin/nodenv init
   ```

   - For **Fish shell**:
     ```fish
     echo 'status --is-interactive; and ~/.nodenv/bin/nodenv init - fish | source' >> ~/.config/fish/config.fish
     ```

   If you are curious, see here to [understand what `init` does](#how-nodenv-hooks-into-your-shell).

3. Restart your shell so that these changes take effect. (Opening a new terminal tab will usually do it.)

#### Shell completions

When _manually_ installing nodenv, it might be useful to note how completion
scripts for various shells work. Completion scripts help with typing nodenv
commands by expanding partially entered nodenv command names and option flags;
typically this is invoked by pressing <kbd>Tab</kbd> key in an interactive
shell.

- The **Bash** completion script for nodenv ships with the project and gets [loaded by the `nodenv init` mechanism](#how-nodenv-hooks-into-your-shell).

- The **Zsh** completion script ships with the project, but needs to be added to FPATH in Zsh before it can be discovered by the shell. One way to do this would be to edit `~/.zshrc`:

  ```sh
  # assuming that nodenv was installed to `~/.nodenv`
  FPATH=~/.nodenv/completions:"$FPATH"

  autoload -U compinit
  compinit
  ```

- The **fish** completion script for nodenv ships with the project and gets [loaded by the `nodenv init` mechanism](#how-nodenv-hooks-into-your-shell).

### Installing Node versions

The `nodenv install` command does not ship with Node.js out-of-the-box, but is provided by the [node-build][] plugin.

Before attempting to install Node.js, **check that [your build environment](https://github.com/nodenv/node-build/wiki#suggested-build-environment) has the necessary tools and libraries**. Then:

```sh
# list latest stable versions:
nodenv install -l

# list all local versions:
nodenv install -L

# install a Node.js version:
nodenv install 24.1.0
```

<!--
For troubleshooting `BUILD FAILED` scenarios, check the [node-build Discussions
section](https://github.com/nodenv/node-build/discussions/categories/build-failures).
-->

> [!NOTE]
> If the `nodenv install` command wasn't found, you can install node-build as a plugin:
>
> ```sh
> git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
> ```

Set a Node.js version to finish installation and start using Node.js:

```sh
nodenv global 24.1.0   # set the default Node.js version for this machine
# or:
nodenv local 24.1.0    # set the Node.js version for this directory
```

Alternatively to the `nodenv install` command, you can download and compile
Node.js manually as a subdirectory of `~/.nodenv/versions`. An entry in that
directory can also be a symlink to a Node.js version installed elsewhere on the
filesystem.

#### Installing npm packages

Select a Node.js version for your project using `nodenv local 24.1.0`, for
example. Then, proceed to install packages as you normally would:

```sh
npm install testdouble
```

Packages installed globally are scoped to the currently-active Node.js version.
If there is a set of npm packages that you wish to be installed (globally) in
every Node.js version, you may be interested in the [nodenv-default-packages][]
plugin.

> [!NOTE]
> You _should not use sudo_ to install packages. Typically, the Node.js
> versions will be installed under your home directory and thus writeable by
> your user. If you get the “you don't have write permissions” error when
> installing packages, it's likely that your "system" Node.js version is still
> a global default. Change that with `nodenv global <version>` and try again.

Check the location where packages are being installed with `npm prefix -g`:

```sh
$ npm prefix -g
~/.nodenv/versions/<version>
```

#### Uninstalling Node.js versions

As time goes on, Node.js versions you install will accumulate in your
`~/.nodenv/versions` directory.

To remove old Node.js versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Node.js version with the `nodenv prefix` command, e.g. `nodenv prefix
20.7.0`.

The [node-build][] plugin provides an `nodenv uninstall` command to
automate the removal process.

## Command Reference

The main nodenv commands you need to know are:

### nodenv versions

Lists all Node.js versions known to nodenv, and shows an asterisk next to
the currently active version.

```console
$ nodenv versions
  20.19.4
  22.17.1
* 24.4.1 (set by /Users/jasonkarns/code/testdouble/.node-version)
  graal+ce-19.2.1
  iojs-3.3.1
```

### nodenv version

Displays the currently active Node.js version, along with information on
how it was set.

```console
$ nodenv version
24.4.1 (set by /Users/jasonkarns/code/testdouble/.node-version)
```

### nodenv local

Sets a local application-specific Node version by writing the version
name to a `.node-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `NODENV_VERSION` environment variable or with the `nodenv shell`
command.

```sh
nodenv local 24.1.0
```

When run without a version number, `nodenv local` reports the currently
configured local version. You can also unset the local version:

```sh
nodenv local --unset
```

### nodenv global

Sets the global version of Node to be used in all shells by writing
the version name to the `~/.nodenv/version` file. This version can be
overridden by an application-specific `.node-version` file, or by
setting the `NODENV_VERSION` environment variable.

```sh
nodenv global 24.1.0
```

The special version name `system` tells nodenv to use the system Node
(detected by searching your `$PATH`).

When run without a version number, `nodenv global` reports the
currently configured global version.

### nodenv shell

Sets a shell-specific Node version by setting the `NODENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

```sh
nodenv shell 20.7.0
```

When run without a version number, `nodenv shell` reports the current
value of `NODENV_VERSION`. You can also unset the shell version:

```sh
nodenv shell --unset
```

Note that you'll need nodenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`NODENV_VERSION` variable yourself:

```sh
export NODENV_VERSION=20.7.0
```

### nodenv rehash

Installs shims for all Node.js executables known to nodenv
(`~/.nodenv/versions/*/bin/*`). You may need to run this command after
installing/uninstalling packages. Or see the [nodenv-package-rehash][] plugin.

```sh
nodenv rehash
```

### nodenv which

Displays the full path to the executable that nodenv will invoke when
you run the given command.

```console
$ nodenv which npm
/Users/will/.nodenv/versions/24.1.0/bin/npm
```

### nodenv whence

Lists all Node.js versions that contain the specified executable name.

```console
$ nodenv whence yarn
24.1.0
20.7.0
```

## Environment variables

You can affect how nodenv operates with the following settings:

| name               | default             | description                                                                              |
| ------------------ | ------------------- | ---------------------------------------------------------------------------------------- |
| `NODENV_VERSION`   |                     | Specifies the Node version to be used. Also see [`nodenv shell`](#nodenv-shell)          |
| `NODENV_ROOT`      | `~/.nodenv`         | Defines the directory under which Node versions and shims reside. Also see `nodenv root` |
| `NODENV_DEBUG`     |                     | Outputs debug information. Also as: `nodenv --debug <subcommand>`                        |
| `NODENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for nodenv hooks.                                 |
| `NODENV_DIR`       | `$PWD`              | Directory to start searching for `.node-version` files.                                  |

### How nodenv hooks into your shell

`nodenv init` is a helper command to hook nodenv into a shell. This helper is part of the recommended installation instructions, but optional, as an experienced user can set up the following tasks manually. The `nodenv init` command has two modes of operation:

1. `nodenv init`: made for humans, this command edits your shell initialization files on disk to add nodenv to shell startup. (Prior to nodenv 1.6.0, this mode only printed user instructions to the terminal, but did nothing else.)

2. `nodenv init -`: made for machines, this command outputs a shell script suitable to be eval'd by the user's shell.

When `nodenv init` is invoked from a Bash shell, for example, it will add the following to the user's `~/.bashrc` or `~/.bash_profile`:

```sh
# Added by `nodenv init` on <DATE>
eval "$(nodenv init - --no-rehash bash)"
```

You may add this line to your shell initialization files manually if you want to avoid running `nodenv init` as part of the setup process. Here is what the eval'd script does:

0. Adds `nodenv` executable to PATH if necessary.

1. Prepends `~/.nodenv/shims` directory to PATH. This is basically the only
   requirement for nodenv to function properly.

2. Installs Bash shell completion for nodenv commands.

3. Regenerates nodenv shims. If this step slows down your shell startup, you
   can invoke `nodenv init -` with the `--no-rehash` flag.

4. Installs the "sh" dispatcher. This bit is also optional, but allows nodenv
   and plugins to change variables in your current shell, making commands like
   `nodenv shell` possible.

### Uninstalling nodenv

The simplicity of nodenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** nodenv managing your Node.js versions, simply comment or remove the
   `nodenv init` line from your shell startup configuration. This will remove
   nodenv shims directory from PATH, and future invocations like `node` will
   execute the system Node.js version, bypassing nodenv completely.

   While disabled, `nodenv` will still be accessible on the command line, but
   your Node.js apps won't be affected by version switching.

2. To completely **uninstall** nodenv, perform step (1) and then remove the
   nodenv root directory. This will **delete all Node.js versions** that were
   installed under `` `nodenv root`/versions/ ``:

   ```sh
   rm -rf "$(nodenv root)"
   ```

   If you've installed nodenv using a package manager, as a final step
   perform the nodenv package removal:
   - Homebrew: `brew uninstall nodenv`
   - Debian, Ubuntu, and their derivatives: `sudo apt purge nodenv`
   - Archlinux and its derivatives: `sudo pacman -R nodenv`

## Development

Tests are executed using [Bats](https://github.com/bats-core/bats-core):

```console
npm test
bats test/<file>.bats
```

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/nodenv/nodenv/issues).

### Credits

Forked from [Sam Stephenson](https://github.com/sstephenson)'s
[rbenv](https://github.com/rbenv/rbenv) by [Will
McKenzie](https://github.com/oinutter) and modified for Node.js.

[nodenv-installer]: https://github.com/nodenv/nodenv-installer#nodenv-installer
[nodenv-package-rehash]: https://github.com/nodenv/nodenv-package-rehash
[nodenv-default-packages]: https://github.com/nodenv/nodenv-default-packages
[node-build]: https://github.com/nodenv/node-build#readme
[hooks]: https://github.com/nodenv/nodenv/wiki/Authoring-plugins#nodenv-hooks
[alternatives]: https://github.com/nodenv/nodenv/wiki/Alternatives
[plugins]: https://github.com/nodenv/nodenv/wiki/Plugins
