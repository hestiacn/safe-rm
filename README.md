<p align="center">
  <img src="logo.png" alt="safe-rm" width="300">
</p>
<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html#license-text"><img src="https://img.shields.io/badge/License-GPL%20v3-blue.svg" alt="License"></a><br>
  <a href="https://github.com/hestiacn/safe-rm/releases/latest"><img src="https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&logo=github&label=Latest%20Release&color=blue" alt="Latest Release"></a>
</p>

# safe-rm

Prevents accidental execution of `rm -rf /*` in the root directory.

`safe-rm` is a wrapper around `/bin/rm` that inspects its arguments
against a configurable list of exclusion paths and refuses to delete
files or directories on that list. Protected paths are skipped with a
warning; all other arguments are passed through unchanged to the real `rm`.

```console
$ rm -rf /usr
safe-rm: Skipping /usr.
```

## Features

- **Protects important paths**: `/`, `/etc`, `/usr`, `/var`, and other
  common system directories are covered by the default protection list
- **Multi-layer configuration**: system-wide + user-specific + built-in
  defaults, merged together
- **Glob support**: wildcards allowed in config files, e.g. `/home/*/Documents`
- **Symlink safety**: resolves symlinks before deletion to prevent
  bypassing the protection list
- **Prebuilt binaries**: Linux (glibc / musl), macOS, FreeBSD, LoongArch64
- **One-line install**: automatic platform detection with localized messages
- **Multi-language**: 30+ languages including Chinese, English, Japanese,
  Korean, German, French, Russian

## Quick Install

### One-line script (recommended)

```sh
curl -fsSL https://raw.githubusercontent.com/hestiacn/safe-rm/master/install.sh | sudo sh
```

The installer automatically:

- Detects OS and CPU architecture
- Chooses the glibc or musl static build based on the system glibc version
- Downloads the matching prebuilt binary
- Installs the binary, config file, PATH script, and man page

### Supported platforms

| Platform | Package | Architecture |
|---|---|---|
| Linux (glibc) | <code>safe-rm-</code>[![Latest](https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&label=&color=blue)](https://github.com/hestiacn/safe-rm/releases/latest)<code>-linux-x86_64-gnu.tar.gz</code> | x86_64 |
| Linux (glibc) | <code>safe-rm-</code>[![Latest](https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&label=&color=blue)](https://github.com/hestiacn/safe-rm/releases/latest)<code>-linux-aarch64-gnu.tar.gz</code> | aarch64 / ARM64 |
| Linux (glibc) | <code>safe-rm-</code>[![Latest](https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&label=&color=blue)](https://github.com/hestiacn/safe-rm/releases/latest)<code>-linux-loongarch64-gnu.tar.gz</code> | LoongArch64 |
| Linux (musl) | <code>safe-rm-</code>[![Latest](https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&label=&color=blue)](https://github.com/hestiacn/safe-rm/releases/latest)<code>-linux-x86_64-musl.tar.gz</code> | x86_64 |
| Linux (musl) | <code>safe-rm-</code>[![Latest](https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&label=&color=blue)](https://github.com/hestiacn/safe-rm/releases/latest)<code>-linux-aarch64-musl.tar.gz</code> | aarch64 / ARM64 |
| macOS | <code>safe-rm-</code>[![Latest](https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&label=&color=blue)](https://github.com/hestiacn/safe-rm/releases/latest)<code>-macos-x86_64.tar.gz</code> | Intel |
| macOS | <code>safe-rm-</code>[![Latest](https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&label=&color=blue)](https://github.com/hestiacn/safe-rm/releases/latest)<code>-macos-aarch64.tar.gz</code> | Apple Silicon |
| FreeBSD | <code>safe-rm-</code>[![Latest](https://img.shields.io/github/v/release/hestiacn/safe-rm?style=flat&label=&color=blue)](https://github.com/hestiacn/safe-rm/releases/latest)<code>-freebsd-x86_64.tar.gz</code> | x86_64 |

> **glibc vs musl**: the installer checks the system glibc version. If
> glibc is older than 2.32, it automatically selects the musl static build
> to avoid errors like `GLIBC_2.32 not found`.

### Build from source

```sh
cargo build --release
sudo make install
```

## Configuration

`safe-rm` reads the protection list from the following sources and
**merges** them (they are not overridden):

1. **System-wide**: `/etc/safe-rm.conf` (or `/usr/local/etc/safe-rm.conf`)
2. **User-specific**: `~/.config/safe-rm`
3. **Legacy user-specific**: `~/.safe-rm` (backward compatibility)
4. **Built-in defaults**: `DEFAULT_PATHS` in the source

### System-wide config example

`/etc/safe-rm.conf`:

```bash
/
/etc
/usr
/usr/lib
/var
```

### User-specific config example

`~/.config/safe-rm`:

```bash
/home/username/documents
/home/username/documents/*
/home/username/.mozilla
```

Glob wildcards are supported, with an expansion limit of 256 entries to
prevent a malicious config from slowing down startup.

### Update the protection list

`update-safe-rm` scans `/` and regenerates the protection list:

```sh
sudo update-safe-rm
```

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/hestiacn/safe-rm/master/install.sh | sudo sh -s -- --uninstall
```

Or locally:

```sh
sudo sh install.sh --uninstall
```

## Project layout

```bash
.
├── .github/              # CI (multi-platform build & release)
├── src/                  # Rust source
├── Cargo.toml            # Project config
├── Cargo.lock
├── Changes               # Changelog
├── COPYING               # GPLv3 license
├── INSTALL               # Install instructions
├── Makefile              # Build/install/test/uninstall
├── Manifest              # File manifest
├── README.md             # This file
├── RELEASING             # Release process
├── TESTING               # Testing notes
├── install.sh            # One-line install/uninstall script
├── safe-rm.1             # man page
├── safe-rm.desktop       # Desktop integration
├── logo.svg / logo.png   # Project logo
```

## Alternatives

If you need stronger protection than `safe-rm`, consider:

- **`alias rm='rm -i'`** — confirm every deletion. Does not protect you
  from habitually answering yes, or from accidentally using `rm -rf`.
- **`chattr +i file`** — uses the filesystem "immutable" attribute; only
  works on filesystems that support it.
- **`trash-cli`** — implements the FreeDesktop.org trashcan spec, allowing
  recovery of deleted files.
  <https://github.com/andreafrancia/trash-cli>
- **`rmfd`** — a fork of GNU coreutils that adds safe-rm-like features
  directly to `rm`.
  <https://github.com/d5h/rmfd>

## License

GPLv3. See [COPYING](COPYING).

Copyright (C) 2008-2026  Francois Marier <francois@fmarier.org>