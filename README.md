# Groom your app’s Node environment with nodenv.

Use nodenv to pick a Node version for your application and guarantee
that your development environment matches production. Put nodenv to work
with [npm](https://www.npmjs.com/) for painless Node upgrades and
bulletproof deployments.

**Powerful in development.** Specify your app's Node version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Node. Just Works™
  from the command line. Override the Node version anytime: just set
  an environment variable.

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
  variables with [nodenv-vars](https://github.com/OiNutter/nodenv-vars).
  See more [plugins on the
  wiki](https://github.com/OiNutter/nodenv/wiki/Plugins).

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Node Version](#choosing-the-node-version)
  * [Locating the Node Installation](#locating-the-node-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [How nodenv hooks into your shell](#how-nodenv-hooks-into-your-shell)
  * [Installing Node Versions](#installing-node-versions)
  * [Uninstalling Node Versions](#uninstalling-node-versions)
* [Command Reference](#command-reference)
  * [nodenv local](#nodenv-local)
  * [nodenv global](#nodenv-global)
  * [nodenv shell](#nodenv-shell)
  * [nodenv versions](#nodenv-versions)
  * [nodenv version](#nodenv-version)
  * [nodenv rehash](#nodenv-rehash)
  * [nodenv which](#nodenv-which)
  * [nodenv whence](#nodenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)

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

Version names to nodenv are simply the names of the directories in
`~/.nodenv/versions`.

## Installation

Please note that at this time, the `nodenv` package in homebrew is *NOT* this
package. This package must be installed using the instructions below.

### Basic GitHub Checkout

This will get you going with the latest version of nodenv and make it
easy to fork and contribute any changes back upstream.

1. Check out nodenv into `~/.nodenv`.

    ~~~ sh
    $ git clone https://github.com/OiNutter/nodenv.git ~/.nodenv
    ~~~

2. Add `~/.nodenv/bin` to your `$PATH` for access to the `nodenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `nodenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(nodenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if nodenv was set up:

    ~~~ sh
    $ type nodenv
    #=> "nodenv is a function"
    ~~~

5. _(Optional)_ Install [node-build][], which provides the
   `nodenv install` command that simplifies the process of
   [installing new Node versions](#installing-node-versions).

#### Upgrading

If you've installed nodenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.nodenv
$ git pull
~~~

To use a specific release of nodenv, check out the corresponding tag:

~~~ sh
$ cd ~/.nodenv
$ git fetch
$ git checkout v0.3.0
~~~

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
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `nodenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `nodenv init -` for yourself to see exactly what happens under the
hood.

### Installing Node Versions

The `nodenv install` command doesn't ship with nodenv out of the box, but is
provided by the [node-build][] project. If you installed it as part of GitHub
checkout process outlined above you should be able to:

~~~ sh
# list all available versions:
$ nodenv install -l

# install a Node version:
$ nodenv install 0.10.26
~~~

Alternatively to the `install` command, you can download and compile
Node manually as a subdirectory of `~/.nodenv/versions/`. An entry in
that directory can also be a symlink to a Node version installed
elsewhere on the filesystem. nodenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Node version.

### Uninstalling Node Versions

As time goes on, Node versions you install will accumulate in your
`~/.nodenv/versions` directory.

To remove old Node versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Node version with the `nodenv prefix` command, e.g. `nodenv prefix
0.8.22`.

The [node-build][] plugin provides an `nodenv uninstall` command to
automate the removal process.

## Command Reference

Like `git`, the `nodenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### nodenv local

Sets a local application-specific Node version by writing the version
name to a `.node-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `NODENV_VERSION` environment variable or with the `nodenv shell`
command.

    $ nodenv local 0.10.0

When run without a version number, `nodenv local` reports the currently
configured local version. You can also unset the local version:

    $ nodenv local --unset

Previous versions of nodenv stored local version specifications in a
file named `.nodenv-version`. For backwards compatibility, nodenv will
read a local version specified in an `.nodenv-version` file, but a
`.node-version` file in the same directory will take precedence.

### nodenv global

Sets the global version of Node to be used in all shells by writing
the version name to the `~/.nodenv/version` file. This version can be
overridden by an application-specific `.node-version` file, or by
setting the `NODENV_VERSION` environment variable.

    $ nodenv global 0.10.26

The special version name `system` tells nodenv to use the system Node
(detected by searching your `$PATH`).

When run without a version number, `nodenv global` reports the
currently configured global version.

### nodenv shell

Sets a shell-specific Node version by setting the `NODENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ nodenv shell 0.11.11

When run without a version number, `nodenv shell` reports the current
value of `NODENV_VERSION`. You can also unset the shell version:

    $ nodenv shell --unset

Note that you'll need nodenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`NODENV_VERSION` variable yourself:

    $ export NODENV_VERSION=0.10.26

### nodenv versions

Lists all Node versions known to nodenv, and shows an asterisk next to
the currently active version.

    $ nodenv versions
      0.8.22
      0.9.12
      * 0.10.0 (set by /Users/will/.nodenv/version)

### nodenv version

Displays the currently active Node version, along with information on
how it was set.

    $ nodenv version
    0.10.0 (set by /Volumes/OiNutter/hubot/.node-version)

### nodenv rehash

Installs shims for all Node executables known to nodenv (i.e.,
`~/.nodenv/versions/*/bin/*`). Run this command after you install a new
version of Node, or install a gem that provides commands.

    $ nodenv rehash

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

## Development

The nodenv source code is [hosted on
GitHub](https://github.com/OiNutter/nodenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/OiNutter/nodenv/issues).

### Credits

Copied from [rbenv](https://github.com/sstephenson/rbenv) and modified to work for node.

### Version History

**0.2.0** (April 18, 2014)

* Updated to match latest version of [rbenv](https://github.com/sstephenson/rbenv). See there for
changelog.

**0.1.0** (March 18, 2013)

* Initial public release. Copied from [rbenv](https://github.com/sstephenson/rbenv)

### License

(The MIT license)

Copyright (c) 2013 Will McKenzie

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


  [node-build]: https://github.com/OiNutter/node-build#readme
