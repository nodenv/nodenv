# Seamlessly manage your app’s Node environment with nodenv.

nodenv is a version manager tool for the Node.js on Unix-like systems. It is useful for switching between multiple Node.js versions on the same machine and for ensuring that each project you are working on always runs on the correct Node.js version.

## How It Works

After nodenv injects itself into your PATH at installation time, any invocation of `node`, `gem`, `bundler`, or other Node.js-related executable will first activate nodenv. Then, nodenv scans the current project directory for a file named `.node-version`. If found, that file determines the version of Node.js that should be used within that directory. Finally, nodenv looks up that Node.js version among those installed under `~/.nodenv/versions/`.

You can choose the Node.js version for your project with, for example:
```sh
cd myproject
# choose Node.js version 3.1.2:
nodenv local 3.1.2
```

Doing so will create or update the `.node-version` file in the current directory with the version that you've chosen. A different project of yours that is another directory might be using a different version of Node.js altogether—nodenv will seamlessly transition from one Node.js version to another when you switch projects.

The simplicity of nodenv has its benefits, but also some downsides. See the [comparison of version managers][alternatives] for more details and some alternatives.

## Installation

On systems with Homebrew package manager, the “Using Package Managers” method is recommended. On other systems, “Basic Git Checkout” might be the easiest way of ensuring that you are always installing the latest version of nodenv.

<details>
<summary>

### Using Package Managers

</summary>

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

   To install the latest
   version, it is recommended to [install nodenv using git](#basic-git-checkout).
   
   
   #### Arch Linux and its derivatives
   
   Archlinux has an [AUR Package](https://aur.archlinux.org/packages/nodenv/) for
   nodenv and you can install it from the AUR using the instructions from this
   [wiki page](https://wiki.archlinux.org/index.php/Arch_User_Repository#Installing_and_upgrading_packages).

2. Learn how to load nodenv in your shell.

    ```sh
    # run this and follow the printed instructions:
    nodenv init
    ```

3. Close your Terminal window and open a new one so your changes take effect.

That's it! You are now ready to [install some Node.js versions](#installing-node-versions).

</details>

<details>
<summary>

### Basic Git Checkout

</summary>

> **Note**  
> For a more automated install, you can use [nodenv-installer](https://github.com/nodenv/nodenv-installer#nodenv-installer). If you do not want to execute scripts downloaded from a web URL or simply prefer a manual approach, follow the steps below.

This will get you going with the latest version of nodenv without needing a system-wide install.

1. Clone nodenv into `~/.nodenv`.


    ```sh
    git clone https://github.com/nodenv/nodenv.git ~/.nodenv
    ```

2. Configure your shell to load nodenv:

   * For **bash**:
     
     _Ubuntu Desktop_ users should configure `~/.bashrc`:
     ```bash
     echo 'eval "$(~/.nodenv/bin/nodenv init - bash)"' >> ~/.bashrc
     ```

     On _other platforms_, bash is usually configured via `~/.bash_profile`:
     ```bash
     echo 'eval "$(~/.nodenv/bin/nodenv init - bash)"' >> ~/.bash_profile
     ```

   * For **Zsh**:
     ```zsh
     echo 'eval "$(~/.nodenv/bin/nodenv init - zsh)"' >> ~/.zshrc
     ```

   * For **Fish shell**:
     ```fish
     echo 'status --is-interactive; and ~/.nodenv/bin/nodenv init - fish | source' >> ~/.config/fish/config.fish
     ```

   If you are curious, see here to [understand what `init` does](#how-nodenv-hooks-into-your-shell).

3. Restart your shell so that these changes take effect. (Opening a new terminal tab will usually do it.)

</details>

### Installing Node versions

The `nodenv install` command does not ship with nodenv out-of-the-box, but is provided by the [node-build][] plugin.

Before attempting to install Node.js, **check that [your build environment](https://github.com/nodenv/node-build/wiki#suggested-build-environment) has the necessary tools and libraries**. Then:

```sh
# list latest stable versions:
nodenv install -l

# list all local versions:
nodenv install -L

# install a Node.js version:
nodenv install 3.1.2
```

> **Note**  
> If the `nodenv install` command wasn't found, you can install node-build as a plugin:
> ```sh
> git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
> ```

Set a Node.js version to finish installation and start using Node.js:
```sh
nodenv global 3.1.2   # set the default Node.js version for this machine
# or:
nodenv local 3.1.2    # set the Node.js version for this directory
```

Alternatively to the `nodenv install` command, you can download and compile Node.js manually as a subdirectory of `~/.nodenv/versions`. An entry in that directory can also be a symlink to a Node.js version installed elsewhere on the filesystem.

#### Installing npm packages

Select a Node.js version for your project using `nodenv local 3.1.2`, for example. Then, proceed to install gems as you normally would:

```sh
cd ~/.nodenv/versions
mkdir lts

# Create a symlink that allows to use "lts/erbium" as a nodenv version
# that always points to the latest Node 12 version that is installed.
ln -s ../12 lts/erbium
```

> **Warning**  
> You _should not use sudo_ to install gems. Typically, the Node.js versions will be installed under your home directory and thus writeable by your user. If you get the “you don't have write permissions” error when installing gems, it's likely that your "system" Node.js version is still a global default. Change that with `nodenv global <version>` and try again.

As time goes on, Node versions you install will accumulate in your
`~/.nodenv/versions` directory.

```sh
gem env home
# => ~/.nodenv/versions/<version>/lib/node/gems/...
```

#### Uninstalling Node.js versions

As time goes on, Node.js versions you install will accumulate in your
`~/.nodenv/versions` directory.

To remove old Node.js versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Node.js version with the `nodenv prefix` command, e.g. `nodenv prefix
2.7.0`.

The [node-build][] plugin provides an `nodenv uninstall` command to
automate the removal process.

## Command Reference

The main nodenv commands you need to know are:

### nodenv versions

Lists all Node.js versions known to nodenv, and shows an asterisk next to
the currently active version.

    $ nodenv versions
      1.8.7-p352
      1.9.2-p290
    * 1.9.3-p327 (set by /Users/sam/.nodenv/version)
      jruby-1.7.1
      rbx-1.2.4
      ree-1.8.7-2011.03

### nodenv version

Displays the currently active Node.js version, along with information on
how it was set.

    $ nodenv version
    1.9.3-p327 (set by /Users/sam/.nodenv/version)

### nodenv local

Sets a local application-specific Node version by writing the version
name to a `.node-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `NODENV_VERSION` environment variable or with the `nodenv shell`
command.

    nodenv local 3.1.2

When run without a version number, `nodenv local` reports the currently
configured local version. You can also unset the local version:

    nodenv local --unset

### nodenv global

Sets the global version of Node to be used in all shells by writing
the version name to the `~/.nodenv/version` file. This version can be
overridden by an application-specific `.node-version` file, or by
setting the `NODENV_VERSION` environment variable.

    nodenv global 3.1.2

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

### nodenv rehash

Installs shims for all Node.js executables known to nodenv (`~/.nodenv/versions/*/bin/*`). Typically you do not need to run this command, as it will run automatically after installing gems.

    nodenv rehash

_**note:** the [package-rehash plugin][package-rehash-plugin] automatically runs `nodenv rehash` whenever an npm package is installed globally_

### nodenv which

Displays the full path to the executable that nodenv will invoke when
you run the given command.

    $ nodenv which npm
    /Users/will/.nodenv/versions/0.10.26/bin/npm

### nodenv whence

Lists all Node.js versions that contain the specified executable name.

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

### How nodenv hooks into your shell

`nodenv init` is a helper command to bootstrap nodenv into a shell. This helper is part of the recommended installation instructions, but optional, as an advanced user can set up the following tasks manually. Here is what the command does when its output is `eval`'d:

0. Adds `nodenv` executable to PATH if necessary.

1. Prepends `~/.nodenv/shims` directory to PATH. This is basically the only requirement for nodenv to function properly.

2. Installs shell completion for nodenv commands.

3. Regenerates nodenv shims. If this step slows down your shell startup, you can invoke `nodenv init -` with the `--no-rehash` flag.

4. Installs the "sh" dispatcher. This bit is also optional, but allows nodenv and plugins to change variables in your current shell, making commands like `nodenv shell` possible.

You can run `nodenv init -` for yourself to inspect the generated script.

### Uninstalling nodenv

The simplicity of nodenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** nodenv managing your Node.js versions, simply remove the `nodenv init` line from your shell startup configuration. This will remove nodenv shims directory from PATH, and future invocations like `node` will execute the system Node.js version, bypassing nodenv completely.

   While disabled, `nodenv` will still be accessible on the command line, but your Node.js apps won't be affected by version switching.

2. To completely **uninstall** nodenv, perform step (1) and then remove the nodenv root directory. This will **delete all Node.js versions** that were installed under `` `nodenv root`/versions/ ``:

       rm -rf "$(nodenv root)"

   If you've installed nodenv using a package manager, as a final step
   perform the nodenv package removal:
   - Homebrew: `brew uninstall nodenv`
   - Debian, Ubuntu, and their derivatives: `sudo apt purge nodenv`
   - Archlinux and its derivatives: `sudo pacman -R nodenv`

## Development

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/nodenv/nodenv/issues).

### Credits

Forked from [Sam Stephenson](https://github.com/sstephenson)'s
[rbenv](https://github.com/rbenv/rbenv) by [Will
McKenzie](https://github.com/oinutter) and modified for node.


  [hooks]: https://github.com/nodenv/nodenv/wiki/Authoring-plugins#nodenv-hooks
  [node-build]: https://github.com/nodenv/node-build#readme
  [nodenv-doctor]: https://github.com/nodenv/nodenv-installer/blob/main/bin/nodenv-doctor
  [nodenv-installer]: https://github.com/nodenv/nodenv-installer#nodenv-installer
  [nodenv-update]: https://github.com/charlesbjohnson/nodenv-update
  [package-rehash-plugin]: https://github.com/nodenv/nodenv-package-rehash
  [alternatives]: https://github.com/rbenv/rbenv/wiki/Other-version-managers
