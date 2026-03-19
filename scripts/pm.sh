#!/usr/bin/env bash
set -euo pipefail
umask 077

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

ROADMAP_PATH="${ROADMAP_PATH:-$ROOT/ROADMAP.md}"

parse() {
  if [ ! -f "$ROADMAP_PATH" ]; then echo "PARSE:SKIP_NO_ROADMAP:$ROADMAP_PATH"; return 0; fi
  python3 "$ROOT/scripts/roadmap/parse_roadmap.py" "$ROADMAP_PATH" --out "$ROOT/artifacts/roadmap.json"
  echo "PARSE:OK:$ROADMAP_PATH -> artifacts/roadmap.json"
}

sync_safe() {
  if [ -z "${GH_REPO:-}" ]; then echo "SYNC:SKIP_NO_REPO"; return 0; fi
  bash "$ROOT/scripts/roadmap/sync_roadmap.sh" "$ROADMAP_PATH" "$GH_REPO"
}

index_sessions() {
  python3 "$ROOT/scripts/sessions/index_sessions.py" --root "$ROOT" --out "$ROOT/docs/sessions.md" || true
}

capture_sessions() {
  # Optional capture: set PM_CAPTURE=1 to enable
  if [ "${PM_CAPTURE:-0}" != "1" ]; then echo "CAPTURE:SKIP"; return 0; fi
  SRC_DIR="${SESSIONS_SRC_DIR:-/mnt/e/sessions-codex}"
  MAX_LINES="${CAPTURE_MAX_LINES:-120}"
  mkdir -p "$ROOT/sessions"
  # pick latest session file(s)
  mapfile -t FILES < <(ls -t "$SRC_DIR"/*.session 2>/dev/null | head -n ${CAPTURE_LIMIT:-1} || true)
  if [ "${#FILES[@]}" -eq 0 ]; then echo "CAPTURE:SKIP_NO_SRC:$SRC_DIR"; return 0; fi
  TS=$(date +%F)
  OUT="$ROOT/sessions/${TS}-Pilot-Excerpt.md"
  python3 "$ROOT/scripts/sessions/sanitize_session.py" --in "${FILES[@]}" --out "$OUT" --max-lines "$MAX_LINES" --title "Redacted Session Excerpt" || true
  echo "CAPTURE:OK:${OUT##$ROOT/}"
}

git_commit() {
  git -C "$ROOT" add -A artifacts/roadmap.json docs/sessions.md 2>/dev/null || true
  if [ "${PM_COMMIT_SESSIONS:-0}" = "1" ]; then
    git -C "$ROOT" add -A sessions/*.md 2>/dev/null || true
  fi
  if git -C "$ROOT" diff --cached --quiet; then echo "COMMIT:SKIP_NO_CHANGES"; return 0; fi
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  git -C "$ROOT" -c user.email="codex-bot@local" -c user.name="Codex Bot" \
    commit -m "docs(roadmap,sessions): update roadmap artifacts and sessions index [PM loop]" \
            -m "When: $ts"
  echo "COMMIT:OK"
  if [ "${PM_PUSH:-0}" = "1" ]; then git -C "$ROOT" push || echo "PUSH:FAIL"; fi
}

cmd="${1:-run}"
case "$cmd" in
  run) parse; sync_safe; capture_sessions; index_sessions; git_commit ;;
  parse) parse ;;
  sync) sync_safe ;;
  capture) capture_sessions ;;
  index) index_sessions ;;
  all) parse; sync_safe; capture_sessions; index_sessions; git_commit ;;
  *) echo "Usage: $0 {run|parse|sync|index|all}" >&2; exit 2 ;;
esac
