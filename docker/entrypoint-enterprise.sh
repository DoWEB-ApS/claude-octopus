#!/usr/bin/env bash
set -euo pipefail

if [[ -d "/workspace" ]]; then
  cd /workspace
fi

# Best effort bootstrap so container sessions start with enterprise policy folders.
if [[ -x "./scripts/orchestrate.sh" ]]; then
  ./scripts/orchestrate.sh setup-enterprise >/dev/null 2>&1 || true
fi

# Optional plugin bootstrap after Claude CLI is available.
# Runs once per plugin fingerprint unless forced.
if [[ "${DOWEB_AUTO_PLUGIN_INSTALL:-true}" == "true" ]] && [[ -x "./install.sh" ]] && command -v claude >/dev/null 2>&1; then
  stamp_dir="${HOME:-/root}/.claude-octopus"
  stamp_file="${stamp_dir}/.plugin-install-stamp"
  mkdir -p "$stamp_dir"

  fingerprint="unknown"
  if command -v shasum >/dev/null 2>&1; then
    files=(./install.sh)
    [[ -f ./.claude-plugin/plugin.json ]] && files+=(./.claude-plugin/plugin.json)
    [[ -f ./.claude-plugin/marketplace.json ]] && files+=(./.claude-plugin/marketplace.json)
    fingerprint="$(cat "${files[@]}" 2>/dev/null | shasum -a 256 | awk '{print $1}')"
  fi

  current_stamp=""
  [[ -f "$stamp_file" ]] && current_stamp="$(cat "$stamp_file" 2>/dev/null || true)"

  if [[ "${DOWEB_FORCE_PLUGIN_INSTALL:-false}" == "true" ]] || [[ "$fingerprint" != "$current_stamp" ]]; then
    echo "[entrypoint] Bootstrapping /doweb Claude plugin..."
    if ./install.sh >/dev/null 2>&1; then
      echo "$fingerprint" > "$stamp_file"
      echo "[entrypoint] Plugin bootstrap complete."
    else
      echo "[entrypoint] WARN: Plugin bootstrap failed (continuing)." >&2
    fi
  fi
fi

exec "$@"
