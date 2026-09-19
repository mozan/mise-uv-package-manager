# mise-uv-package-manager

A [mise](https://mise.jdx.dev/) bootstrap package-manager plugin for
user-wide Python CLI tools managed by [`uv tool`](https://docs.astral.sh/uv/guides/tools/).

It makes declarations such as this possible:

```toml
[tools]
uv = "latest"

[bootstrap.plugins]
uv = "https://github.com/mozan/mise-uv-package-manager"

[bootstrap.packages]
"uv:ruff" = "latest"
"uv:black" = "26.3.1"
```

## What it manages

This plugin manages **uv tools** (`uv tool install`), not dependencies in a
Python project's `pyproject.toml`.

Each uv tool is installed in its own isolated environment. Executables are
linked into uv's tool bin directory (`uv tool dir --bin`).

## Features

- detects installed tools with `uv tool list`
- installs missing tools
- supports exact version pins
- changing a pin upgrades or downgrades the tool
- supports `latest` upgrades
- supports mise package pruning via `uv tool uninstall`
- handles package names case-insensitively for status matching
- supports Linux, macOS, and Windows (subject to uv/mise support)

## Install the plugin locally

From this repository:

```sh
mise plugins link --force package:uv "$PWD"
```

Then configure:

```toml
[tools]
uv = "latest"

[bootstrap.packages]
"uv:ruff" = "latest"
```

Check and apply:

```sh
mise bootstrap packages status
mise bootstrap --dry-run
mise bootstrap
```

## Install from GitHub

Push this repository, then:

```toml
[tools]
uv = "latest"

[bootstrap.plugins]
uv = "https://github.com/mozan/mise-uv-package-manager"

[bootstrap.packages]
"uv:ruff" = "latest"
"uv:black" = "26.3.1"
```

A full `mise bootstrap` installs package plugins first, then built-in
bootstrap packages, then `[tools]`, and finally plugin-managed packages.
Therefore `uv` declared in `[tools]` is available when this plugin runs.

## Version behavior

Pinned declaration:

```toml
"uv:black" = "26.3.1"
```

is installed as:

```sh
uv tool install 'black==26.3.1'
```

If the observed version differs, mise selects it for installation/upgrade and
the plugin runs `uv tool install` again. Re-installation replaces the previous
tool environment and its constraint, allowing both upgrades and downgrades.

For:

```toml
"uv:ruff" = "latest"
```

normal bootstrap ensures the tool exists. An explicit package upgrade uses:

```sh
uv tool upgrade ruff
```

so uv resolves the newest version permitted by its installation metadata.

## PATH

This plugin does not modify your shell configuration.

Find uv's executable directory with:

```sh
uv tool dir --bin
```

If it is not on PATH, uv provides:

```sh
uv tool update-shell
```

Run that explicitly if desired; status hooks intentionally never mutate shell
state.

## Pruning

The plugin implements `PackageUninstall`, enabling mise's explicit ownership-
aware pruning:

```sh
mise bootstrap packages prune --manager uv --dry-run
mise bootstrap packages prune --manager uv
```

mise only offers packages for pruning when its ownership ledger says they were
installed by the plugin and they are no longer protected by loaded config.

## Scope and limitations

The bootstrap key is the Python distribution name, for example `ruff`,
`black`, or `httpie`. This initial plugin intentionally models the common
PyPI-distribution case. Advanced `uv tool install` inputs such as Git URLs,
extras, `--with`, alternate indexes, or per-tool Python selection are not
encoded in the simple `[bootstrap.packages]` name/version interface.

## Development notes

mise package plugins require both:

- `hooks/package_installed.lua`
- `hooks/package_install.lua`

`PackageUpgrade` and `PackageUninstall` are optional and implemented here.

The status hook is side-effect free and only reports requested package
identities. Action hooks operate only on the batch supplied by mise.
