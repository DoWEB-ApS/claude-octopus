#!/usr/bin/env bash
set -euo pipefail

if [[ -d "/workspace" ]]; then
  cd /workspace
fi

# Best effort bootstrap so container sessions start with enterprise policy folders.
if [[ -x "./scripts/orchestrate.sh" ]]; then
  ./scripts/orchestrate.sh setup-enterprise >/dev/null 2>&1 || true
fi

exec "$@"
