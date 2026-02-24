#!/usr/bin/env bash
set -euo pipefail

TASKMASTER_FILE_DEFAULT=".taskmaster/tasks/tasks.json"

tm_err() {
  echo "taskmaster-adapter: $*" >&2
}

tm_file() {
  local f="${TASKMASTER_FILE:-$TASKMASTER_FILE_DEFAULT}"
  echo "$f"
}

tm_require() {
  local f
  f="$(tm_file)"
  if [[ ! -f "$f" ]]; then
    tm_err "Task file not found: $f"
    return 1
  fi
  if ! jq empty "$f" >/dev/null 2>&1; then
    tm_err "Invalid JSON in task file: $f"
    return 1
  fi
}

tm_next_ready() {
  tm_require
  local f
  f="$(tm_file)"

  # Ready = status pending/planned and all dependencies are completed/done.
  jq -c '
    def by_id: map({key: (.id|tostring), value: .}) | from_entries;
    . as $all
    | ($all | by_id) as $idx
    | [ .[]
        | select((.status // "pending") | test("^(pending|planned)$"))
        | . as $t
        | ((.dependencies // []) | all((($idx[(.|tostring)]?.status // "pending") | test("^(completed|done)$")))) as $deps_ok
        | select($deps_ok)
      ]
    | sort_by(.priority // 999, .id)
    | .[0] // empty
  ' "$f"
}

tm_set_status() {
  local id="$1"
  local status="$2"
  tm_require
  local f tmp
  f="$(tm_file)"
  tmp="${f}.tmp.$$"

  jq --arg id "$id" --arg status "$status" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
    map(if ((.id|tostring) == $id)
        then .status = $status | .updated_at = $ts
        else . end)
  ' "$f" > "$tmp"
  mv "$tmp" "$f"
}

tm_add_note() {
  local id="$1"
  local note="$2"
  tm_require
  local f tmp
  f="$(tm_file)"
  tmp="${f}.tmp.$$"

  jq --arg id "$id" --arg note "$note" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
    map(if ((.id|tostring) == $id)
        then .notes = ((.notes // "") + "\n[" + $ts + "] " + $note)
        else . end)
  ' "$f" > "$tmp"
  mv "$tmp" "$f"
}

tm_list_blockers() {
  tm_require
  local f
  f="$(tm_file)"

  jq -c '[ .[] | select((.status // "") == "blocked") ]' "$f"
}

cmd="${1:-}"
shift || true

case "$cmd" in
  next-ready)
    tm_next_ready
    ;;
  set-status)
    [[ $# -lt 2 ]] && { tm_err "usage: set-status <id> <status>"; exit 1; }
    tm_set_status "$1" "$2"
    ;;
  add-note)
    [[ $# -lt 2 ]] && { tm_err "usage: add-note <id> <note>"; exit 1; }
    tm_add_note "$1" "$2"
    ;;
  blockers)
    tm_list_blockers
    ;;
  *)
    cat <<EOF
Usage: taskmaster.sh <command>
  next-ready
  set-status <id> <status>
  add-note <id> <note>
  blockers

Environment:
  TASKMASTER_FILE=.taskmaster/tasks/tasks.json
EOF
    exit 1
    ;;
esac
