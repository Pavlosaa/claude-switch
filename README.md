# claude-switch

Manage installed versions of the [Claude Code](https://claude.com/claude-code) CLI. Download any released version directly from the npm registry, switch between them with a single symlink, and roll back instantly when an update breaks something.

```
$ claude-switch list
Installed versions (darwin-arm64)
Location: /Users/you/.local/share/claude/versions
    2.1.98
    2.1.104
  * 2.1.114  (active)

$ claude-switch upgrade
Latest stable: 2.1.116
Downloading 2.1.116 for darwin-arm64 ...
Downloaded 2.1.116 -> /Users/you/.local/share/claude/versions/2.1.116
Switched to 2.1.116
```

## Why

The official Claude Code installer keeps one version on your system. When a new release introduces a regression, your only option is to wait for a fix or hand-pin an older version yourself. `claude-switch` keeps every version you've used in `~/.local/share/claude/versions/` and flips a single symlink to activate one — no reinstall, no guessing which `.tgz` you need from npm.

## Install

### Direct download

```sh
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/Pavlosaa/claude-switch/main/claude-switch \
  -o ~/.local/bin/claude-switch
chmod +x ~/.local/bin/claude-switch
```

Make sure `~/.local/bin` is on your `PATH`. If not, add this to `~/.zshrc` or `~/.bashrc`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

### Homebrew

```sh
brew install Pavlosaa/tap/claude-switch
```

> The Homebrew tap is published separately at [`Pavlosaa/homebrew-tap`](https://github.com/Pavlosaa/homebrew-tap). It will be available after the first tagged release.

### From source

```sh
git clone https://github.com/Pavlosaa/claude-switch.git
ln -s "$PWD/claude-switch/claude-switch" ~/.local/bin/claude-switch
```

## Usage

```
claude-switch                  List installed versions
claude-switch list             List installed versions
claude-switch remote           List all versions available in npm registry
claude-switch latest           Switch to latest installed version
claude-switch <version>        Switch to an installed version
claude-switch download         Download latest stable version
claude-switch download <ver>   Download a specific version
claude-switch upgrade          Download latest stable + switch to it
claude-switch help             Show help
```

### Examples

Download the latest stable release and switch to it:

```sh
claude-switch upgrade
```

Pin an older version after a bad release:

```sh
claude-switch download 2.1.114
claude-switch 2.1.114
```

See what's available on the registry:

```sh
claude-switch remote
```

## How it works

`claude-switch` reads platform-specific binaries from the official npm packages:

- `@anthropic-ai/claude-code-darwin-arm64`
- `@anthropic-ai/claude-code-darwin-x64`
- `@anthropic-ai/claude-code-linux-x64`
- `@anthropic-ai/claude-code-linux-arm64`
- `@anthropic-ai/claude-code-linux-x64-musl`
- `@anthropic-ai/claude-code-linux-arm64-musl`

The right package is chosen automatically based on `uname -s`, `uname -m`, and (on Linux) whether the system uses musl libc.

Each downloaded version is stored as `~/.local/share/claude/versions/<version>`. The active version is the file that `~/.local/bin/claude` symlinks to. Switching versions is a `ln -sf` — no daemon, no shim, no shell hooks.

## Configuration

Override defaults with environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `CLAUDE_SWITCH_VERSIONS_DIR` | `~/.local/share/claude/versions` | Where versioned binaries live |
| `CLAUDE_SWITCH_SYMLINK` | `~/.local/bin/claude` | Path to the active `claude` symlink |
| `CLAUDE_SWITCH_REGISTRY` | `https://registry.npmjs.org` | npm registry URL |

## Requirements

- `bash` 4+ (any modern macOS or Linux)
- `curl`, `tar`, `python3`
- macOS (arm64 or x64) or Linux (arm64, x64, glibc or musl)

Windows is not supported natively — use [WSL](https://learn.microsoft.com/en-us/windows/wsl/).

## Maintainer docs

See [docs/RUNBOOK.md](docs/RUNBOOK.md) for release process, hotfix procedure, platform support, and troubleshooting.

## License

[MIT](LICENSE)
