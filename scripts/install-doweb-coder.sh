#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_SCRIPT="$REPO_ROOT/scripts/doweb-coder.sh"

pick_default_target() {
  local candidate
  for candidate in "/usr/local/bin" "/opt/homebrew/bin"; do
    if [[ -d "$candidate" ]] && [[ -w "$candidate" ]]; then
      echo "$candidate/doweb-coder"
      return 0
    fi
  done
  echo "$HOME/.local/bin/doweb-coder"
}

TARGET_PATH="${1:-$(pick_default_target)}"

if [[ ! -x "$SOURCE_SCRIPT" ]]; then
  echo "ERROR: source script missing or not executable: $SOURCE_SCRIPT" >&2
  exit 1
fi

TARGET_DIR="$(dirname "$TARGET_PATH")"
if [[ ! -d "$TARGET_DIR" ]]; then
  mkdir -p "$TARGET_DIR"
fi

if [[ ! -w "$TARGET_DIR" ]]; then
  echo "ERROR: target directory is not writable: $TARGET_DIR" >&2
  echo "Try one of:" >&2
  echo "  1) bash ./scripts/install-doweb-coder.sh \"$HOME/.local/bin/doweb-coder\"" >&2
  echo "  2) sudo bash ./scripts/install-doweb-coder.sh /usr/local/bin/doweb-coder" >&2
  exit 1
fi

cat > "$TARGET_PATH" <<EOF
#!/usr/bin/env bash
set -euo pipefail

export DOWEB_HOME="$REPO_ROOT"
exec "$SOURCE_SCRIPT" "\$@"
EOF

chmod +x "$TARGET_PATH"
chmod +x "$SOURCE_SCRIPT"

echo "Installed launcher: $TARGET_PATH"
echo "Pinned DOWEB_HOME: $REPO_ROOT"
echo "Run from any project directory: doweb-coder"
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
  echo "NOTE: Add to PATH: export PATH=\"$TARGET_DIR:\$PATH\""
fi
