#!/bin/bash
# Claude /doweb Plugin Installer
#
# Hard-pinned enterprise installer for DoWEB fork.
# No auto-detection to avoid drift.

set -euo pipefail

MARKETPLACE_URL="https://github.com/DoWEB-ApS/claude-octopus"
MARKETPLACE_NAME="doweb-plugins"
PACKAGE_NAME="claude-octopus"
PLUGIN_NAME="doweb"
PLUGIN_SPEC="${PACKAGE_NAME}@${MARKETPLACE_NAME}"

echo "Installing /doweb plugin..."

if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: Claude Code CLI ('claude') not found in PATH."
  echo ""
  echo "Install Claude Code first, then install plugin with:"
  echo "  claude plugin marketplace add $MARKETPLACE_URL"
  echo "  claude plugin install $PLUGIN_SPEC --scope user"
  echo "  claude plugin enable $PLUGIN_NAME --scope user"
  echo "  claude plugin update $PLUGIN_NAME --scope user"
  exit 1
fi

echo "Using Claude plugin manager:"
echo "  Marketplace URL:  $MARKETPLACE_URL"
echo "  Marketplace Name: $MARKETPLACE_NAME"
echo "  Package:          $PACKAGE_NAME"
echo "  Plugin Name:      $PLUGIN_NAME"

# Ensure marketplace exists and is fresh (idempotent).
claude plugin marketplace add "$MARKETPLACE_URL" >/dev/null 2>&1 || true
claude plugin marketplace update "$MARKETPLACE_NAME" >/dev/null 2>&1 || true

# Install package (idempotent).
claude plugin install "$PLUGIN_SPEC" --scope user >/dev/null 2>&1 || true

# Enable/update by plugin runtime name; fallback to package name for compatibility.
claude plugin enable "$PLUGIN_NAME" --scope user >/dev/null 2>&1 || \
  claude plugin enable "$PACKAGE_NAME" --scope user >/dev/null 2>&1 || true
claude plugin update "$PLUGIN_NAME" --scope user >/dev/null 2>&1 || \
  claude plugin update "$PACKAGE_NAME" --scope user >/dev/null 2>&1 || true

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo "1. Restart Claude Code"
echo "2. Run: /doweb:setup-enterprise"
echo ""
echo "Troubleshooting:"
echo "- Verify install: claude plugin list"
echo "- If commands don't appear, check: ~/.claude/debug/*.txt"
echo ""
