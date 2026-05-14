#!/bin/bash

# health_check.sh - Environment and pilot health validation
# Returns: 0 = healthy, 1 = issues detected

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"
JQ="$PILOT_ROOT/.tmp-bin/jq"
if [ ! -f "$JQ" ]; then
    JQ="jq"
fi
export PATH="$PATH:$PILOT_ROOT/.tmp-bin"

set -euo pipefail

echo "DEBUG: PILOT_ROOT is $PILOT_ROOT"
echo "DEBUG: JQ is $JQ"

# Colors (if terminal supports it)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES=0
WARNINGS=0

# Logging
log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++)) || true
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((ISSUES++)) || true
}

log_info() {
    echo -e "[INFO] $1"
}

echo "=== Health Check: $(basename "$PILOT_ROOT") ==="
echo "Timestamp: $(date -Iseconds)"
echo ""

# Check 1: Required files exist
echo "--- Required Files ---"

REQUIRED_FILES=(
    "AGENTS.md"
    "CLAUDE.md"
    "GEMINI.md"
    "ROADMAP.md"
    ".github/copilot-instructions.md"
    "artifacts/state.json"
    "artifacts/agent-handover.json"
    "scripts/pm.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PILOT_ROOT/$file" ]; then
        log_ok "$file exists"
    else
        log_fail "$file missing"
    fi
done

echo ""

# Check 2: Required directories exist
echo "--- Required Directories ---"

REQUIRED_DIRS=(
    ".claude/skills"
    ".codex/skills"
    ".gemini/skills"
    ".github"
    "artifacts"
    "artifacts/logs"
    "docs"
    "scripts"
    "sessions"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$PILOT_ROOT/$dir" ]; then
        log_ok "$dir/ exists"
    else
        log_fail "$dir/ missing"
    fi
done

echo ""

# Check 3: Scripts are executable
echo "--- Script Permissions ---"

SCRIPTS=(
    "scripts/pm.sh"
    "scripts/health_check.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$PILOT_ROOT/$script" ]; then
        if [ -x "$PILOT_ROOT/$script" ]; then
            log_ok "$script is executable"
        else
            log_warn "$script not executable (run: chmod +x $script)"
        fi
    fi
done

echo ""

# Check 4: JSON files are valid
echo "--- JSON Validation ---"

# Set JQ path to local wrapper if it exists, otherwise check PATH
JQ="$PILOT_ROOT/.tmp-bin/jq"
if [ ! -f "$JQ" ]; then
    JQ="jq"
fi

if "$JQ" --version &> /dev/null; then
    JSON_FILES=(
        "artifacts/state.json"
        "artifacts/agent-handover.json"
        "data/scam-ioc.json"
        "data/salary-benchmarks.json"
    )

    for file in "${JSON_FILES[@]}"; do
        if [ -f "$PILOT_ROOT/$file" ]; then
            if jq empty "$PILOT_ROOT/$file" 2>/dev/null; then
                log_ok "$file is valid JSON"
            else
                log_fail "$file is invalid JSON"
            fi
        fi
    done
else
    log_warn "jq not installed - skipping JSON validation"
fi

echo ""

# Check 5: Git repository status
echo "--- Git Status ---"

if [ -d "$PILOT_ROOT/.git" ]; then
    log_ok "Git repository initialized"

    cd "$PILOT_ROOT"
    if git status &> /dev/null; then
        UNCOMMITTED=$(git status --porcelain | wc -l)
        if [ "$UNCOMMITTED" -eq 0 ]; then
            log_ok "Working tree clean"
        else
            log_warn "$UNCOMMITTED uncommitted changes"
        fi
    fi
else
    log_fail "Git repository not initialized"
fi

echo ""

# Check 6: Lock file status
echo "--- Lock Status ---"

LOCK_FILE="$PILOT_ROOT/artifacts/.agent-lock"
if [ -f "$LOCK_FILE" ]; then
    LOCK_AGE=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
    if [ "$LOCK_AGE" -gt 1800 ]; then
        log_warn "Stale lock detected (${LOCK_AGE}s old) - consider removing"
    else
        log_info "Active lock: $(cat "$LOCK_FILE")"
    fi
else
    log_ok "No lock file (available for work)"
fi

echo ""

# Check 7: External dependencies
echo "--- External Dependencies ---"

DEPS=(
    "git"
    "bash"
)

OPTIONAL_DEPS=(
    "jq"
    "curl"
)

# Set JQ path to local wrapper if it exists, otherwise check PATH
JQ="$PILOT_ROOT/.tmp-bin/jq"
if [ ! -f "$JQ" ]; then
    JQ="jq"
fi

for dep in "${DEPS[@]}"; do
    if command -v "$dep" &> /dev/null; then
        log_ok "$dep available"
    else
        log_fail "$dep not found (required)"
    fi
done

for dep in "${OPTIONAL_DEPS[@]}"; do
    if [ "$dep" = "jq" ]; then
        if "$JQ" --version &> /dev/null; then
            log_ok "jq available ($("$JQ" --version | head -n 1))"
        else
            log_warn "jq not found (optional)"
        fi
    else
        if command -v "$dep" &> /dev/null; then
            log_ok "$dep available"
        else
            log_warn "$dep not found (optional)"
        fi
    fi
done

echo ""

# Check 8: Registry integrity
echo "--- Registry Integrity ---"

REGISTRY_DIR="$PILOT_ROOT/artifacts/registry"
JOBS_FILE="$REGISTRY_DIR/jobs.jsonl"
APPLIED_FILE="$REGISTRY_DIR/applied.jsonl"

if [ -d "$REGISTRY_DIR" ]; then
    log_ok "Registry directory exists"

    # Check JSONL validity (every line must be valid JSON)
    if [ -f "$JOBS_FILE" ] && [ -s "$JOBS_FILE" ]; then
        if command -v jq &> /dev/null; then
            BAD_LINES=0
            while IFS= read -r line; do
                if ! echo "$line" | jq empty 2>/dev/null; then
                    ((BAD_LINES++)) || true
                fi
            done < "$JOBS_FILE"
            if [ "$BAD_LINES" -eq 0 ]; then
                JOB_COUNT=$(wc -l < "$JOBS_FILE")
                UNIQUE_COUNT=$(grep -o '"fingerprint":"[^"]*"' "$JOBS_FILE" | sort -u | wc -l)
                log_ok "jobs.jsonl valid ($JOB_COUNT entries, $UNIQUE_COUNT unique)"
                if [ "$JOB_COUNT" -gt $(( UNIQUE_COUNT * 2 )) ]; then
                    log_warn "jobs.jsonl needs compaction ($JOB_COUNT entries vs $UNIQUE_COUNT unique)"
                fi
            else
                log_fail "jobs.jsonl has $BAD_LINES invalid lines"
            fi
        else
            log_warn "jq not available - skipping JSONL validation"
        fi
    else
        log_info "jobs.jsonl is empty (no jobs registered)"
    fi

    if [ -f "$APPLIED_FILE" ] && [ -s "$APPLIED_FILE" ]; then
        APP_COUNT=$(wc -l < "$APPLIED_FILE")
        log_ok "applied.jsonl has $APP_COUNT entries"
    else
        log_info "applied.jsonl is empty (no applications logged)"
    fi

    # Check for orphaned locks
    ORPHAN_LOCKS=0
    for lock_dir in "$REGISTRY_DIR/locks/"*.lock; do
        [ -d "$lock_dir" ] || continue
        ((ORPHAN_LOCKS++)) || true
        LOCK_AGE_REG=0
        if [ -f "$lock_dir/info.json" ]; then
            LOCK_AGE_REG=$(( $(date +%s) - $(stat -c %Y "$lock_dir/info.json" 2>/dev/null || echo 0) ))
        fi
        if [ "$LOCK_AGE_REG" -gt 1800 ]; then
            log_warn "Stale registry lock: $(basename "$lock_dir") (${LOCK_AGE_REG}s old)"
        else
            log_info "Active registry lock: $(basename "$lock_dir") (${LOCK_AGE_REG}s old)"
        fi
    done
    [ "$ORPHAN_LOCKS" -eq 0 ] && log_ok "No orphaned registry locks"
else
    log_warn "Registry directory not found (run: ./scripts/registry.sh migrate)"
fi

echo ""

# Check 9: IDE Simulation Integrity
echo "--- IDE Simulation ---"

IDE_BINARIES=(
    "bin/antigravity.sh"
    "bin/agent-manager.sh"
    "bin/editor.sh"
)

for bin in "${IDE_BINARIES[@]}"; do
    if [ -f "$PILOT_ROOT/$bin" ]; then
        log_ok "$bin exists"
    else
        log_fail "$bin missing"
    fi
done

IDE_CONFIGS=(
    "config/profiles/default.json"
    "config/profiles/architect.json"
    "config/profiles/developer.json"
    "config/profiles/tester.json"
    "config/connectivity/gemini.json"
)

for config in "${IDE_CONFIGS[@]}"; do
    if [ -f "$PILOT_ROOT/$config" ]; then
        log_ok "$config exists"
    else
        log_fail "$config missing"
    fi
done

# Run connectivity check as part of health
bash "$PILOT_ROOT/scripts/check_connectivity.sh" | sed 's/^/  /'

echo ""

# Summary
echo "=== Summary ==="
echo "Issues: $ISSUES"
echo "Warnings: $WARNINGS"

if [ "$ISSUES" -gt 0 ]; then
    echo ""
    echo -e "${RED}Health check FAILED${NC}"
    echo "Run ./scripts/auto_heal.sh to attempt automatic remediation"
    exit 1
else
    if [ "$WARNINGS" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Health check PASSED with warnings${NC}"
    else
        echo ""
        echo -e "${GREEN}Health check PASSED${NC}"
    fi
    exit 0
fi
