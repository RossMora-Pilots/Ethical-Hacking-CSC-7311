#!/bin/bash
set -eu

# auto_heal.sh - Self-remediation for common pilot issues

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PILOT_ROOT/artifacts/logs/auto_heal.log"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date -Iseconds)] $*" | tee -a "$LOG_FILE"
}

log "INFO" "Starting auto-heal sequence"

# 1. Fix CRLF issues (common on Windows)
log "INFO" "Normalizing line endings (stripping CRLFs)"
find "$PILOT_ROOT" -type f \( -name "*.sh" -o -name "*.json" -o -name "*.md" \) -not -path "*/.*" | while read -r file; do
    if grep -q $'\r' "$file"; then
        log "FIX" "Removing CRLF from $file"
        # Try sed, fallback to tr
        if sed -i 's/\r//' "$file" 2>/dev/null; then
            :
        else
            tr -d '\r' < "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        fi
    fi
done

# 2. Fix script permissions
log "INFO" "Ensuring scripts are executable"
find "$PILOT_ROOT/scripts" -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
find "$PILOT_ROOT/bin" -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

# 3. Clean stale locks
LOCK_FILE="$PILOT_ROOT/artifacts/.agent-lock"
if [ -f "$LOCK_FILE" ]; then
    LOCK_AGE=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
    if [ "$LOCK_AGE" -gt 1800 ]; then
        log "FIX" "Removing stale lock file ($LOCK_AGE seconds old)"
        rm -f "$LOCK_FILE"
    fi
fi

# 4. Re-parse roadmap if JSON is missing
if [ ! -f "$PILOT_ROOT/artifacts/roadmap.json" ]; then
    log "FIX" "roadmap.json missing, re-parsing"
    bash "$PILOT_ROOT/scripts/pm.sh" parse
fi

log "INFO" "Auto-heal sequence complete"
