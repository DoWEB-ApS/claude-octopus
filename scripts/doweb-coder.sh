#!/usr/bin/env bash
set -euo pipefail

print_usage() {
  cat <<USAGE
Usage: doweb-coder [options] [-- <command> [args...]]

Builds the /doweb enterprise agent image, then starts it with the current
working directory mounted at /project inside the container.

Options:
  --project-dir <path>   Mount this directory as /project (default: current dir)
  --auto-update          Pull latest claude-octopus changes before build/run
  --no-update            Disable auto-update for this run
  --no-build             Skip image build step
  --no-cache             Build image without Docker cache
  -h, --help             Show this help

Examples:
  doweb-coder
  doweb-coder --project-dir /code/my-app
  doweb-coder --auto-update
  doweb-coder -- ./scripts/orchestrate.sh -d /project next-task
USAGE
}

resolve_script_dir() {
  local source="${BASH_SOURCE[0]}"
  while [[ -L "$source" ]]; do
    local dir
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    source="$(readlink "$source")"
    [[ "$source" != /* ]] && source="$dir/$source"
  done
  cd -P "$(dirname "$source")" && pwd
}

SCRIPT_DIR="$(resolve_script_dir)"
DEFAULT_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"
DOWEB_HOME="${DOWEB_HOME:-$DEFAULT_HOME}"
COMPOSE_FILE="$DOWEB_HOME/docker-compose.yml"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "ERROR: docker-compose.yml not found at: $COMPOSE_FILE" >&2
  echo "Set DOWEB_HOME to your claude-octopus repo path." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not installed or not in PATH" >&2
  exit 1
fi

PROJECT_DIR="$PWD"
DO_BUILD=true
DO_UPDATE=false
BUILD_NO_CACHE=false

if [[ "${DOWEB_AUTO_UPDATE:-}" == "1" || "${DOWEB_AUTO_UPDATE:-}" == "true" ]]; then
  DO_UPDATE=true
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir)
      [[ $# -lt 2 ]] && { echo "ERROR: --project-dir requires a value" >&2; exit 1; }
      PROJECT_DIR="$2"
      shift 2
      ;;
    --no-build)
      DO_BUILD=false
      shift
      ;;
    --no-cache)
      BUILD_NO_CACHE=true
      shift
      ;;
    --auto-update)
      DO_UPDATE=true
      shift
      ;;
    --no-update)
      DO_UPDATE=false
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "ERROR: Project directory does not exist: $PROJECT_DIR" >&2
  exit 1
fi

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

compose=(docker compose -f "$COMPOSE_FILE" --project-directory "$DOWEB_HOME" --profile enterprise)

if [[ "$DO_UPDATE" == "true" ]]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "[doweb-coder] WARN: git not found; skipping auto-update"
  elif ! git -C "$DOWEB_HOME" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[doweb-coder] WARN: $DOWEB_HOME is not a git repository; skipping auto-update"
  elif [[ -n "$(git -C "$DOWEB_HOME" status --porcelain 2>/dev/null)" ]]; then
    echo "[doweb-coder] WARN: local changes in $DOWEB_HOME; skipping auto-update"
  else
    echo "[doweb-coder] Auto-updating $DOWEB_HOME (git pull --ff-only)..."
    if git -C "$DOWEB_HOME" pull --ff-only; then
      :
    else
      echo "[doweb-coder] WARN: auto-update failed; continuing with current version"
    fi
  fi
fi

if [[ "$DO_BUILD" == "true" ]]; then
  echo "[doweb-coder] Building doweb-agent image..."
  build_args=(build)
  if [[ "$BUILD_NO_CACHE" == "true" ]]; then
    build_args+=(--no-cache)
  fi
  build_args+=(doweb-agent)
  "${compose[@]}" "${build_args[@]}"
fi

echo "[doweb-coder] Starting container with /project -> $PROJECT_DIR"
run_args=(run --rm -v "$PROJECT_DIR:/project" -w /project doweb-agent)
if [[ $# -gt 0 ]]; then
  run_args+=("$@")
else
  run_args+=(bash)
fi

exec "${compose[@]}" "${run_args[@]}"
