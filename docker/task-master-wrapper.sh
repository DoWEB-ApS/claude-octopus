#!/usr/bin/env bash
set -euo pipefail

self_path="$(readlink -f "$0" 2>/dev/null || echo "$0")"

run_if_available() {
  local candidate="$1"
  local candidate_path
  candidate_path="$(command -v "$candidate" 2>/dev/null || true)"
  [[ -z "$candidate_path" ]] && return 1
  candidate_path="$(readlink -f "$candidate_path" 2>/dev/null || echo "$candidate_path")"
  [[ "$candidate_path" == "$self_path" ]] && return 1
  exec "$candidate_path" "$@"
}

# Prefer globally installed CLI binaries if available.
run_if_available task-master "$@"
run_if_available task-master-ai "$@"
run_if_available taskmaster "$@"

# Fallback to npx (no global install required).
if command -v npx >/dev/null 2>&1; then
  exec npx -y task-master-ai "$@"
fi

echo "ERROR: Task Master CLI not found and npx unavailable." >&2
echo "Install npm or add task-master-ai globally." >&2
exit 127

