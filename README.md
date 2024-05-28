# Seamlessly manage your app’s Node environment with nodenv.

Use nodenv to pick a Node version for your application and guarantee
that your development environment matches production. Put nodenv to work
with [npm](https://www.npmjs.com/) for painless Node upgrades and
bulletproof deployments.

**Powerful in development.** Specify your app's Node version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Node. Just Works™
  from the command line.
  Override the Node version anytime: just set an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. With nodenv and you'll never again need to `cd`
  in a cron job or Chef recipe to ensure you've selected the right runtime.
  The Node version dependency lives in one place—your app—so upgrades and
  rollbacks are atomic, even when you switch versions.

**One thing well.** nodenv is concerned solely with switching Node
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own Node versions, or
  use the [node-build][]
  plugin to automate the process. Specify per-application environment
  variables with [nodenv-vars](https://github.com/nodenv/nodenv-vars).
  See more [plugins on the
  wiki](https://github.com/nodenv/nodenv/wiki/Plugins).

[**Why choose nodenv?**](https://github.com/nodenv/nodenv/wiki/Why-nodenv%3F)

## Table of Contents

<!-- toc -->

- [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Node Version](#choosing-the-node-version)
  * [Locating the Node Installation](#locating-the-node-installation)
- [Installation](#installation)
  * [Using Package Managers](#using-package-managers)
  * [Basic GitHub Checkout](#basic-github-checkout)
    + [Upgrading with Git](#upgrading-with-git)
    + [Updating the list of available Node versions](#updating-the-list-of-available-node-versions)
  * [How nodenv hooks into your shell](#how-nodenv-hooks-into-your-shell)
  * [Installing Node versions](#installing-node-versions)
  * [Uninstalling Node versions](#uninstalling-node-versions)
  * [Uninstalling nodenv](#uninstalling-nodenv)
- [Command Reference](#command-reference)
  * [nodenv local](#nodenv-local)
  * [nodenv global](#nodenv-global)
  * [nodenv shell](#nodenv-shell)
  * [nodenv versions](#nodenv-versions)
  * [nodenv version](#nodenv-version)
  * [nodenv rehash](#nodenv-rehash)
  * [nodenv which](#nodenv-which)
  * [nodenv whence](#nodenv-whence)
- [Environment variables](#environment-variables)
- [Development](#development)
  * [Credits](#credits)

<!-- tocstop -->

## How It Works

At a high level, nodenv intercepts Node commands using shim
executables injected into your `PATH`, determines which Node version
has been specified by your application, and passes your commands along
to the correct Node installation.

### Understanding PATH

When you run a command like `node` or `npm`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

nodenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.nodenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, nodenv maintains shims in that
directory to match every Node command across every installed version
of Node—`node`, `npm`, and so on.

Shims are lightweight executables that simply pass your command along
to nodenv. So with nodenv installed, when you run, say, `npm`, your
operating system will do the following:

* Search your `PATH` for an executable file named `npm`
* Find the nodenv shim named `npm` at the beginning of your `PATH`
* Run the shim named `npm`, which in turn passes the command along to
  nodenv

### Choosing the Node Version

When you execute a shim, nodenv determines which Node version to use by
reading it from the following sources, in this order:

1. The `NODENV_VERSION` environment variable, if specified. You can use
   the [`nodenv shell`](#nodenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.node-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.node-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.node-version` file in the current working
   directory with the [`nodenv local`](#nodenv-local) command.

4. The global `~/.nodenv/version` file. You can modify this file using
   the [`nodenv global`](#nodenv-global) command. If the global version
   file is not present, nodenv assumes you want to use the "system"
   Node—i.e. whatever version would be run if nodenv weren't in your
   path.

### Locating the Node Installation

Once nodenv has determined which version of Node your application has
specified, it passes the command along to the corresponding Node
installation.

Each Node version is installed into its own directory under
`~/.nodenv/versions`. For example, you might have these versions
installed:

* `~/.nodenv/versions/0.10.36/`
* `~/.nodenv/versions/0.12.0/`
* `~/.nodenv/versions/iojs-1.0.0/`

Version names to nodenv are simply the names of the directories or symlinks in
`~/.nodenv/versions`.

## Installation

### Using Package Managers

1. Install nodenv using one of the following approaches.

   #### Homebrew
   
   On macOS or Linux, we recommend installing nodenv with [Homebrew](https://brew.sh).
   
   ```sh
   brew install nodenv
   ```
   
   #### Debian, Ubuntu, and their derivatives
       
   Presently, `nodenv` is not available in the Debian or Ubuntu package
   repositories.
   [Consider contributing!](https://github.com/nodenv/nodenv/issues/210) 
   
   #### Arch Linux and its derivatives
   
   Archlinux has an [AUR Package](https://aur.archlinux.org/packages/nodenv/) for
   nodenv and you can install it from the AUR using the instructions from this
   [wiki page](https://wiki.archlinux.org/index.php/Arch_User_Repository#Installing_and_upgrading_packages).

2. Set up nodenv in your shell.

    ```sh
    nodenv init
    ```

   Follow the printed instructions to [set up nodenv shell integration](#how-nodenv-hooks-into-your-shell).

3. Close your Terminal window and open a new one so your changes take
   effect.

4. Verify that nodenv is properly set up using this [nodenv-doctor][] script:

    ```sh
    curl -fsSL https://github.com/nodenv/nodenv-installer/raw/main/bin/nodenv-doctor | bash
    ```

    ```sh
    Checking for `nodenv' in PATH: /usr/local/bin/nodenv
    Checking for nodenv shims in PATH: OK
    Checking `nodenv install' support: /usr/local/bin/nodenv-install (node-build 3.0.22-4-g49c4cb9)
    Counting installed Node versions: none
      There aren't any Node versions installed under `~/.nodenv/versions'.
      You can install Node versions like so: nodenv install 2.2.4
    Auditing installed plugins: OK
    ```

5. That's it! Installing nodenv includes node-build, so now you're ready to
   [install some Node versions](#installing-node-versions) using
   `nodenv install`.


### Basic GitHub Checkout

For a more automated install, you can use [nodenv-installer][].
If you prefer a manual approach, follow the steps below.

This will get you going with the latest version of nodenv without needing
a systemwide install.

1. Clone nodenv into `~/.nodenv`.


    ```sh
    git clone https://github.com/nodenv/nodenv.git ~/.nodenv
    ```

    Optionally, try to compile dynamic bash extension to speed up nodenv. Don't
    worry if it fails; nodenv will still work normally:

    ```sh
    cd ~/.nodenv && src/configure && make -C src
    ```

2. Add `~/.nodenv/bin` to your `$PATH` for access to the `nodenv`
   command-line utility.

   * For **bash**:

     Ubuntu Desktop users should configure `~/.bashrc`:
     ```bash
     echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.bashrc
     ```

     On other platforms, bash is usually configured via `~/.bash_profile`:
     ```bash
     echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.bash_profile
     ```

   * For **Zsh**:
     ```zsh
     echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.zshrc
     ```

   * For **Fish shell**:
     ```fish
     set -Ux fish_user_paths $HOME/.nodenv/bin $fish_user_paths
     ```

3. Set up nodenv in your shell.

   ```sh
   ~/.nodenv/bin/nodenv init
   ```

   Follow the printed instructions to [set up nodenv shell integration](#how-nodenv-hooks-into-your-shell).

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.)

5. Verify that nodenv is properly set up using this [nodenv-doctor][] script:

    ```sh
    curl -fsSL https://github.com/nodenv/nodenv-installer/raw/main/bin/nodenv-doctor | bash
    ```

    ```sh
    Checking for `nodenv' in PATH: /usr/local/bin/nodenv
    Checking for nodenv shims in PATH: OK
    Checking `nodenv install' support: /usr/local/bin/nodenv-install (node-build 3.0.22-4-g49c4cb9)
    Counting installed Node versions: none
      There aren't any Node versions installed under `~/.nodenv/versions'.
      You can install Node versions like so: nodenv install 2.2.4
    Auditing installed plugins: OK
    ```

6. _(Optional)_ Install [node-build][], which provides the
   `nodenv install` command that simplifies the process of
   [installing new Node versions](#installing-node-versions).

#### Upgrading with Git

If you've installed nodenv manually using Git, you can upgrade to the
latest version by pulling from GitHub:

```sh
cd ~/.nodenv
git pull
```

To use a specific release of nodenv, check out the corresponding tag:

~~~ sh
$ cd ~/.nodenv
$ git fetch
$ git checkout v0.3.0
~~~

Alternatively, check out the [nodenv-update][] plugin which provides a
command to update nodenv along with all installed plugins.

```sh
$ nodenv update
```

#### Updating the list of available Node versions

If you're using the `nodenv install` command, then the list of available Node versions is not automatically updated when pulling from the nodenv repo.
To do this manually:

```sh
cd ~/.nodenv/plugins/node-build
git pull
```

### How nodenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`nodenv init` is the only command that crosses the line of loading
extra commands into your shell. Here's what `nodenv init` actually does:

1. Sets up your shims path. This is the only requirement for nodenv to
   function properly. You can do this by hand by prepending
   `~/.nodenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.nodenv/completions/nodenv.bash` will set that
   up. There is also a `~/.nodenv/completions/nodenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `nodenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   nodenv and plugins to change variables in your current shell, making
   commands like `nodenv shell` possible. The sh dispatcher doesn't do
   anything invasive like override `cd` or hack your shell prompt, but if
   for some reason you need `nodenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `nodenv init -` for yourself to see exactly what happens under the
hood.

### Installing Node versions

The `nodenv install` command doesn't ship with nodenv out of the box, but is
provided by the [node-build][] project. If you installed it as part of GitHub
checkout process outlined above you should be able to:

```sh
# list latest stable versions:
nodenv install -l

# list all local versions:
nodenv install -L

# install a Node version:
nodenv install 16.13.2
```

Set a Node version to finish installation and start using commands `nodenv global 18.14.1` or `nodenv local 18.14.1`

Alternatively to the `install` command, you can download and compile
Node manually as a subdirectory of `~/.nodenv/versions/`. An entry in
that directory can also be a symlink to a Node version installed
elsewhere on the filesystem. nodenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Node version.
Additionally, `nodenv` has special support for an `lts/` subdirectory inside
`versions/`. This works great with the
[`nodenv-aliases`](https://github.com/nodenv/nodenv-aliases) plugin, for example:

```sh
cd ~/.nodenv/versions
mkdir lts

# Create a symlink that allows to use "lts/erbium" as a nodenv version
# that always points to the latest Node 12 version that is installed.
ln -s ../12 lts/erbium
```

### Uninstalling Node versions

As time goes on, Node versions you install will accumulate in your
`~/.nodenv/versions` directory.

To remove old Node versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Node version with the `nodenv prefix` command, e.g. `nodenv prefix
0.8.22`.

The [node-build][] plugin provides an `nodenv uninstall` command to
automate the removal process.

### Uninstalling nodenv

The simplicity of nodenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** nodenv managing your Node versions, simply remove the
  `nodenv init` line from your shell startup configuration. This will
  remove nodenv shims directory from `$PATH`, and future invocations like
  `node` will execute the system Node version, as before nodenv.

   While disabled, `nodenv` will still be accessible on the command line, but your Node
  apps won't be affected by version switching.

2. To completely **uninstall** nodenv, perform step (1) and then remove
   its root directory. This will **delete all Node versions** that were
   installed under `` `nodenv root`/versions/ `` directory:

        rm -rf `nodenv root`

   If you've installed nodenv using a package manager, as a final step
   perform the nodenv package removal:
   - Homebrew: `brew uninstall nodenv`
   - Archlinux and its derivatives: `sudo pacman -R nodenv`

## Command Reference

Like `git`, the `nodenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### nodenv local

Sets a local application-specific Node version by writing the version
name to a `.node-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `NODENV_VERSION` environment variable or with the `nodenv shell`
command.

    nodenv local 0.10.0

When run without a version number, `nodenv local` reports the currently
configured local version. You can also unset the local version:

    nodenv local --unset

### nodenv global

Sets the global version of Node to be used in all shells by writing
the version name to the `~/.nodenv/version` file. This version can be
overridden by an application-specific `.node-version` file, or by
setting the `NODENV_VERSION` environment variable.

    nodenv global 0.10.26

The special version name `system` tells nodenv to use the system Node
(detected by searching your `$PATH`).

When run without a version number, `nodenv global` reports the
currently configured global version.

### nodenv shell

Sets a shell-specific Node version by setting the `NODENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    nodenv shell 0.11.11

When run without a version number, `nodenv shell` reports the current
value of `NODENV_VERSION`. You can also unset the shell version:

    nodenv shell --unset

Note that you'll need nodenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`NODENV_VERSION` variable yourself:

    export NODENV_VERSION=0.10.26

### nodenv versions

Lists all Node versions known to nodenv, and shows an asterisk next to
the currently active version.

    $ nodenv versions
      0.8.22
      0.9.12
      * 0.10.0 (set by /Users/will/.nodenv/version)

This will also list symlinks to specific Node versions inside the `~/.nodenv/versions` or `~/.nodenv/versions/lts` directories.

### nodenv version

Displays the currently active Node version, along with information on
how it was set.

    $ nodenv version
    0.10.0 (set by /Users/OiNutter/.nodenv/version)

### nodenv rehash

Installs shims for all Node executables known to nodenv (i.e.,
`~/.nodenv/versions/*/bin/*` and `~/.nodenv/versions/lts/*/bin/*`). Run this command after you install a new
version of Node, or install an npm package that provides an executable binary.

    $ nodenv rehash

_**note:** the [package-rehash plugin][package-rehash-plugin] automatically runs `nodenv rehash` whenever an npm package is installed globally_

### nodenv which

Displays the full path to the executable that nodenv will invoke when
you run the given command.

    $ nodenv which npm
    /Users/will/.nodenv/versions/0.10.26/bin/npm

### nodenv whence

Lists all Node versions with the given command installed.

    $ nodenv whence npm
    0.10.0
    0.9.12
    0.8.22

## Environment variables

You can affect how nodenv operates with the following settings:

name | default | description
-----|---------|------------
`NODENV_VERSION` | | Specifies the Node version to be used.<br>Also see [`nodenv shell`](#nodenv-shell)
`NODENV_ROOT` | `~/.nodenv` | Defines the directory under which Node versions and shims reside.<br>Also see `nodenv root`
`NODENV_DEBUG` | | Outputs debug information.<br>Also as: `nodenv --debug <subcommand>`
`NODENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for nodenv hooks.
`NODENV_DIR` | `$PWD` | Directory to start searching for `.node-version` files.

## Development

The nodenv source code is [hosted on
GitHub](https://github.com/nodenv/nodenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/nodenv/nodenv/issues).

### Credits

Forked from [Sam Stephenson](https://github.com/sstephenson)'s
[rbenv](https://github.com/rbenv/rbenv) by [Will
McKenzie](https://github.com/oinutter) and modified for node.


  [hooks]: https://github.com/rbenv/rbenv/wiki/Authoring-plugins#rbenv-hooks
  [node-build]: https://github.com/nodenv/node-build#readme
  [nodenv-doctor]: https://github.com/nodenv/nodenv-installer/blob/main/bin/nodenv-doctor
  [nodenv-installer]: https://github.com/nodenv/nodenv-installer#nodenv-installer
  [nodenv-update]: https://github.com/charlesbjohnson/nodenv-update
  [package-rehash-plugin]: https://github.com/nodenv/nodenv-package-rehash
