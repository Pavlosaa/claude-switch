# RUNBOOK

Operational procedures for `claude-switch`.

## Repos

| Repo | Purpose |
| --- | --- |
| [`Pavlosaa/claude-switch`](https://github.com/Pavlosaa/claude-switch) | Source code, releases |
| [`Pavlosaa/homebrew-tap`](https://github.com/Pavlosaa/homebrew-tap) | Homebrew tap mirroring `Formula/claude-switch.rb` |

## Releasing a new version

Release a new version when behavior changes (new command, bug fix, platform support).
Follow [SemVer](https://semver.org/): patch for fixes, minor for features, major for breaking changes.

### 1. Prepare the release

```sh
cd /Users/vysloup/_AI_Tools/ClaudeCodeAgenticBuilder/_mini/claude-switch

# Make sure main is clean and pushed
git status
git push
```

### 2. Tag and push

```sh
VERSION=v0.1.1   # update accordingly
git tag "$VERSION"
git push origin "$VERSION"
```

### 3. Create GitHub release

```sh
gh release create "$VERSION" --title "$VERSION" --generate-notes
```

### 4. Compute tarball SHA256

```sh
SHA256=$(curl -fsSL "https://github.com/Pavlosaa/claude-switch/archive/refs/tags/${VERSION}.tar.gz" | shasum -a 256 | awk '{print $1}')
echo "$SHA256"
```

### 5. Update Homebrew formula in both repos

Update `Formula/claude-switch.rb` — change `url` (version) and `sha256`:

```ruby
url "https://github.com/Pavlosaa/claude-switch/archive/refs/tags/v0.1.1.tar.gz"
sha256 "<new-sha256>"
```

Commit in the source repo:

```sh
git add Formula/claude-switch.rb
git commit -m "chore: bump Homebrew formula to ${VERSION}"
git push
```

Mirror to the tap repo:

```sh
git clone https://github.com/Pavlosaa/homebrew-tap.git /tmp/homebrew-tap 2>/dev/null \
  || (cd /tmp/homebrew-tap && git pull)

cp Formula/claude-switch.rb /tmp/homebrew-tap/Formula/claude-switch.rb
cd /tmp/homebrew-tap
git add Formula/claude-switch.rb
git commit -m "chore: bump claude-switch to ${VERSION}"
git push
cd -
```

### 6. Verify

```sh
brew update
brew upgrade claude-switch        # if already installed
# or
brew uninstall claude-switch && brew install Pavlosaa/tap/claude-switch
claude-switch help
```

## Hotfix a broken release

If a release is broken:

1. **Do not delete the GitHub release** — users may already have it cached. Mark it as pre-release instead:
   ```sh
   gh release edit "$VERSION" --prerelease
   ```
2. Fix the bug on `main`.
3. Cut a new patch release (e.g. `v0.1.2`) following the standard process above.
4. Optionally pin Homebrew formula back to the last good version while preparing the fix.

## Rolling back the active Claude Code version

User-facing rollback (the whole point of this tool):

```sh
claude-switch list                     # see what's installed
claude-switch <previous-version>       # switch
```

If the desired old version isn't installed:

```sh
claude-switch download 2.1.114
claude-switch 2.1.114
```

## Adding a new platform

The supported platforms map 1:1 to npm sub-packages of `@anthropic-ai/claude-code`. To add a new one:

1. Confirm the npm package exists, e.g. `npm view @anthropic-ai/claude-code-<os>-<arch>`.
2. Extend `detect_platform()` in `claude-switch` with the new `uname -s` / `uname -m` / libc combo.
3. Test on the target platform.
4. Bump the version and follow the release process.

## Troubleshooting

### `failed to fetch registry metadata`

- Check internet connectivity.
- Check if `https://registry.npmjs.org/@anthropic-ai/claude-code-<platform>` returns valid JSON.
- A custom registry can be set via `CLAUDE_SWITCH_REGISTRY`.

### `version X not found in npm registry`

The npm registry can prune old versions. Check what's still available:

```sh
claude-switch remote
```

If a known-good old version was pruned, the only options are:
- Use a still-available version
- Restore from a local backup of `~/.local/share/claude/versions/`

### Homebrew formula installs but binary doesn't run

- Check `brew test claude-switch` — runs the formula's test block.
- Verify the binary executes: `$(brew --prefix)/bin/claude-switch help`.
- If platform detection fails, run `bash -x $(brew --prefix)/bin/claude-switch help` to trace.

## Local development

Edit and test locally before tagging a release:

```sh
# Run the working copy directly
./claude-switch help

# Override paths to avoid clobbering your real installation
CLAUDE_SWITCH_VERSIONS_DIR=/tmp/claude-versions \
CLAUDE_SWITCH_SYMLINK=/tmp/claude \
  ./claude-switch download
```

Validate the Homebrew formula syntax:

```sh
ruby -c Formula/claude-switch.rb
```

If you have a local Homebrew install, install from the working tree:

```sh
brew install --build-from-source ./Formula/claude-switch.rb
```
