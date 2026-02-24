#!/usr/bin/env bash
# Validate that plugin name remains "doweb" in plugin.json
# This prevents breaking all command prefixes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_JSON="$PROJECT_ROOT/.claude-plugin/plugin.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Validating plugin name..."

# Check if plugin.json exists
if [[ ! -f "$PLUGIN_JSON" ]]; then
    echo -e "${RED}❌ ERROR: plugin.json not found at $PLUGIN_JSON${NC}"
    exit 1
fi

# Extract plugin name from plugin.json
PLUGIN_NAME=$(grep '"name"' "$PLUGIN_JSON" | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

# Expected plugin name
EXPECTED_NAME="doweb"

# Validate
if [[ "$PLUGIN_NAME" != "$EXPECTED_NAME" ]]; then
    echo -e "${RED}❌ CRITICAL ERROR: Plugin name is incorrect!${NC}"
    echo ""
    echo -e "  Current:  ${YELLOW}\"$PLUGIN_NAME\"${NC}"
    echo -e "  Expected: ${GREEN}\"$EXPECTED_NAME\"${NC}"
    echo ""
    echo "The plugin name MUST be \"doweb\" to maintain correct command prefixes."
    echo "Commands like /doweb:next-task and /doweb:run-project will break otherwise."
    echo ""
    echo "See .claude-plugin/PLUGIN_NAME_LOCK.md for details."
    echo ""
    exit 1
fi

# Also validate that package.json has correct name
PACKAGE_JSON="$PROJECT_ROOT/package.json"
if [[ -f "$PACKAGE_JSON" ]]; then
    PACKAGE_NAME=$(grep '"name"' "$PACKAGE_JSON" | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    EXPECTED_PACKAGE_NAME="claude-octopus"

    if [[ "$PACKAGE_NAME" != "$EXPECTED_PACKAGE_NAME" ]]; then
        echo -e "${YELLOW}⚠️  WARNING: Package name should be \"$EXPECTED_PACKAGE_NAME\" but is \"$PACKAGE_NAME\"${NC}"
    fi
fi

echo -e "${GREEN}✅ Plugin name is correct: \"$PLUGIN_NAME\"${NC}"
echo "   Commands will work as: /doweb:setup-enterprise, /doweb:run-project, etc."

exit 0
