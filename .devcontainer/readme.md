# MTG Json CLI Development Container

This devcontainer is used to aid in local development as
well as CI for consistent operations.

## Running as Root

The container image does not set a non-root default user with the
`USER` instruction. GitHub Actions
[requires](https://docs.github.com/en/actions/reference/workflows-and-actions/dockerfile-support#user)
that Docker actions run as the default Docker user (root). Setting a
different default user prevents access to the `GITHUB_WORKSPACE`
directory and causes permission errors in actions such as
[actions/checkout](https://github.com/actions/checkout/issues/956).

For local development the `devcontainer.json` sets `remoteUser` to
`ubuntu`, so interactive sessions still run as a non-root user.

## Potential Problems

### SSH Key not found

**Problem** If git is configured on the host to sign commits, they could
fail inside of a dev container. The most likely cause is
the `signingkey` is pointing to a file on the host which
is not mounted to the container.

**Solution** The simplest solution is to embed the public
key into your gitconfig. This can be done by putting `key::`
before the key contents as the signing key. This tells git
the key is embedded and not a file reference.

```gitconfig
[user]
  name = {your name}
  email = {your email}
  signingkey = key::ecdsa-sha2-nistp256 {key} {email for key}
```
