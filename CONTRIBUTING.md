# Development

## Git configuration for fetching rbenv upstream

In order to continually pull changes from rbenv into nodenv, it is necessary to
add rbenv as a Git remote. However, this adds some complication because (by
default), Git tags for nodenv and rbenv will collide. (ie, rbenv's `v1.0.0`
tag conflicts with nodenv's `v1.0.0`) Additionally, having rbenv's tags exist
locally introduces complications to the release process: `git push
--follow-tags` would push rbenv's tags to nodenv's `origin` remote.

The following special Git configuration avoids these and other headaches while
still allowing `origin` to be pushed using `--tags` or `--follow-tags`
options—without the risk of pushing rbenv's tags into nodenv's tagspace. The
configuration assumes nodenv's remote is `origin`, and rbenv's remote is
`rbenv`.

1. Configure rbenv to not fetch tags by default:

   ```console
   git config remote.rbenv.tagOpt --no-tags
   ```
> [!WARNING]
> The `--tags` option to `fetch` et. al. will override this setting.

2. Fetch rbenv's tags to their own refspec namespace (`rbtags`, in this case):

   ```console
   git config --add remote.rbenv.fetch '+refs/tags/*:refs/rbtags/*'
   ```

Resulting snippet in `.git/config`:

```gitconfig
[remote "origin"]
    url = git@github.com:nodenv/nodenv.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[remote "rbenv"]
    url = git@github.com:rbenv/rbenv.git
    fetch = +refs/heads/*:refs/remotes/rbenv/*
    fetch = +refs/tags/*:refs/rbtags/*
    tagopt = --no-tags
```

To reference rbenv's tags, use the fully qualified refspec: `refs/rbtags/vX.Y.Z`

```console
git show refs/rbtags/v1.1.2
git checkout refs/rbtags/v1.1.2
git merge refs/rbtags/v1.1.2
```
