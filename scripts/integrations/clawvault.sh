#!/usr/bin/env bash
set -euo pipefail

VAULT_ROOT_DEFAULT=".doweb/clawvault"

cv_root() {
  echo "${DOWEB_MEMORY_PATH:-$VAULT_ROOT_DEFAULT}"
}

cv_init() {
  local root
  root="$(cv_root)"
  mkdir -p "$root"/{decisions,deviations,task-evidence,session-notes,retrospectives}
}

cv_slug() {
  local s="$1"
  s="$(printf '%s' "$s" | tr '[:upper:]' '[:lower:]')"
  s="${s// /-}"
  s="${s//[^a-z0-9._-]/}"
  echo "$s"
}

cv_append_entry() {
  local category="$1"
  local task_id="$2"
  local title="$3"
  local body="$4"
  cv_init

  local root ts slug file
  root="$(cv_root)"
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  slug="$(cv_slug "$task_id")"
  file="$root/$category/${slug}.md"

  cat >> "$file" <<EOF
## $title
- timestamp: $ts
- task_id: $task_id

$body

---

EOF
}

cv_write_decision() {
  local task_id="$1"
  local summary="$2"
  local rationale="$3"
  local options="${4:-n/a}"
  local risks="${5:-n/a}"
  cv_append_entry "decisions" "$task_id" "Decision: $summary" "- rationale: $rationale
- options_considered: $options
- risks: $risks"
}

cv_write_deviation() {
  local task_id="$1"
  local planned="$2"
  local implemented="$3"
  local reason="$4"
  cv_append_entry "deviations" "$task_id" "Deviation" "- planned: $planned
- implemented: $implemented
- reason: $reason"
}

cv_write_evidence() {
  local task_id="$1"
  local evidence="$2"
  cv_append_entry "task-evidence" "$task_id" "Evidence" "$evidence"
}

cv_append_session_note() {
  local note="$1"
  cv_init
  local root file ts
  root="$(cv_root)"
  file="$root/session-notes/$(date -u +%Y-%m-%d).md"
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf -- "- [%s] %s\n" "$ts" "$note" >> "$file"
}

cv_load_context() {
  local task_id="$1"
  cv_init
  local root slug
  root="$(cv_root)"
  slug="$(cv_slug "$task_id")"

  for f in "$root/decisions/${slug}.md" "$root/deviations/${slug}.md" "$root/task-evidence/${slug}.md"; do
    [[ -f "$f" ]] && { echo "### $(basename "$f")"; tail -n 80 "$f"; echo; }
  done
}

cmd="${1:-}"
shift || true

case "$cmd" in
  init)
    cv_init
    ;;
  decision)
    [[ $# -lt 3 ]] && { echo "usage: clawvault.sh decision <task_id> <summary> <rationale> [options] [risks]" >&2; exit 1; }
    cv_write_decision "$@"
    ;;
  deviation)
    [[ $# -lt 4 ]] && { echo "usage: clawvault.sh deviation <task_id> <planned> <implemented> <reason>" >&2; exit 1; }
    cv_write_deviation "$@"
    ;;
  evidence)
    [[ $# -lt 2 ]] && { echo "usage: clawvault.sh evidence <task_id> <evidence_markdown>" >&2; exit 1; }
    cv_write_evidence "$@"
    ;;
  session-note)
    [[ $# -lt 1 ]] && { echo "usage: clawvault.sh session-note <note>" >&2; exit 1; }
    cv_append_session_note "$*"
    ;;
  context)
    [[ $# -lt 1 ]] && { echo "usage: clawvault.sh context <task_id>" >&2; exit 1; }
    cv_load_context "$1"
    ;;
  *)
    cat <<EOF
Usage: clawvault.sh <command>
  init
  decision <task_id> <summary> <rationale> [options] [risks]
  deviation <task_id> <planned> <implemented> <reason>
  evidence <task_id> <evidence_markdown>
  session-note <note>
  context <task_id>

Environment:
  DOWEB_MEMORY_PATH=.doweb/clawvault
EOF
    exit 1
    ;;
esac
