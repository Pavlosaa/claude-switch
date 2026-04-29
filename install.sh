#!/usr/bin/env bash
# Install claude-switch to ~/.local/bin (or $INSTALL_DIR if set).
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
SCRIPT_URL="${SCRIPT_URL:-https://raw.githubusercontent.com/Pavlosaa/claude-switch/main/claude-switch}"

mkdir -p "$INSTALL_DIR"
curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/claude-switch"
chmod +x "$INSTALL_DIR/claude-switch"

echo "Installed claude-switch to $INSTALL_DIR/claude-switch"

case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    echo "Run 'claude-switch help' to get started."
    ;;
  *)
    echo
    echo "WARNING: $INSTALL_DIR is not in your PATH."
    echo "Add this to your shell profile (~/.zshrc, ~/.bashrc):"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac
