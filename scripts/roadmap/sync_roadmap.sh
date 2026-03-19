#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -lt 2 ]; then echo "Usage: $0 <roadmap_path> <owner/repo>" >&2; exit 2; fi
ROADMAP="$1"; REPO="$2"; HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/../.." && pwd)"
ARTIFACTS_DIR="$ROOT/artifacts"; mkdir -p "$ARTIFACTS_DIR"
python3 "$HERE/parse_roadmap.py" "$ROADMAP" --out "$ARTIFACTS_DIR/roadmap.json"
if [ -z "${GH_TOKEN:-}" ] && [ -f "$HOME/.ccpm/secrets/github-token" ]; then export GH_TOKEN="$(cat "$HOME/.ccpm/secrets/github-token" 2>/dev/null || true)"; fi
if ! command -v gh >/dev/null 2>&1; then echo "SYNC_STATUS:SKIPPED_NO_GH"; exit 0; fi
python3 "$HERE/sync_issues.py" --roadmap "$ROADMAP" --repo "$REPO" --json "$ARTIFACTS_DIR/roadmap.json" || { echo "SYNC_STATUS:ERROR"; exit 1; }
echo "SYNC_STATUS:OK"

