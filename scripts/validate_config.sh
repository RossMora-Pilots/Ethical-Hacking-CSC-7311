#!/bin/bash
JQ="$PILOT_ROOT/.tmp-bin/jq"
set -euo pipefail

# validate_config.sh - Configuration compliance and drift detection
# Compares pilot against canonical blueprint structure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"
BLUEPRINT_ROOT="${BLUEPRINT_ROOT:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DRIFT=0
COMPLIANT=0

echo "=== Configuration Validation ==="
echo "Pilot: $(basename "$PILOT_ROOT")"
if [ -n "$BLUEPRINT_ROOT" ]; then
    echo "Blueprint: $BLUEPRINT_ROOT"
else
    echo "Blueprint: (none — standalone validation)"
fi
echo "Timestamp: $(date -Iseconds)"
echo ""

# Check if we're validating the blueprint itself
if [ -n "$BLUEPRINT_ROOT" ] && [ "$PILOT_ROOT" = "$BLUEPRINT_ROOT" ]; then
    echo "Note: Validating blueprint against itself (self-check mode)"
    echo ""
fi

# Validation 1: Required files present
echo "--- Required Files ---"

REQUIRED_FILES=(
    "AGENTS.md"
    "CLAUDE.md"
    "GEMINI.md"
    "ROADMAP.md"
    "CONTRIBUTING.md"
    ".github/copilot-instructions.md"
    "artifacts/state.json"
    "artifacts/agent-handover.json"
    "scripts/pm.sh"
    "scripts/health_check.sh"
    "docs/HANDOVER-PROTOCOL.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PILOT_ROOT/$file" ]; then
        echo -e "${GREEN}[PRESENT]${NC} $file"
        ((COMPLIANT++)) || true
    else
        echo -e "${RED}[MISSING]${NC} $file"
        if [ -n "$BLUEPRINT_ROOT" ]; then
            echo "         Fix: cp $BLUEPRINT_ROOT/$file $PILOT_ROOT/$file"
        else
            echo "         Fix: Create $PILOT_ROOT/$file"
        fi
        ((DRIFT++)) || true
    fi
done

echo ""

# Validation 2: Required directories
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
    "unified-skills"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$PILOT_ROOT/$dir" ]; then
        echo -e "${GREEN}[PRESENT]${NC} $dir/"
        ((COMPLIANT++)) || true
    else
        echo -e "${RED}[MISSING]${NC} $dir/"
        echo "         Fix: mkdir -p $PILOT_ROOT/$dir"
        ((DRIFT++)) || true
    fi
done

echo ""

# Validation 3: JSON schema compliance
echo "--- JSON Schema Validation ---"

JQ="$PILOT_ROOT/.tmp-bin/jq"
if [ ! -f "$JQ" ]; then
    JQ="jq"
fi

if "$JQ" --version &> /dev/null; then
    # Validate state.json schema
    STATE_FILE="$PILOT_ROOT/artifacts/state.json"
    if [ -f "$STATE_FILE" ]; then
        REQUIRED_KEYS=("pilot" "version" "status" "tasks" "health")
        MISSING_KEYS=()

        for key in "${REQUIRED_KEYS[@]}"; do
            if ! "$JQ" -e ".$key" "$STATE_FILE" > /dev/null 2>&1; then
                MISSING_KEYS+=("$key")
            fi
        done

        if [ ${#MISSING_KEYS[@]} -eq 0 ]; then
            echo -e "${GREEN}[VALID]${NC} state.json has required keys"
            ((COMPLIANT++)) || true
        else
            echo -e "${RED}[INVALID]${NC} state.json missing keys: ${MISSING_KEYS[*]}"
            echo "         Fix: Reinitialize with ./scripts/pm.sh init"
            ((DRIFT++)) || true
        fi
    fi

    # Validate agent-handover.json schema
    HANDOVER_FILE="$PILOT_ROOT/artifacts/agent-handover.json"
    if [ -f "$HANDOVER_FILE" ]; then
        REQUIRED_KEYS=("schema_version" "pilot" "handovers")
        MISSING_KEYS=()

        for key in "${REQUIRED_KEYS[@]}"; do
            if ! "$PILOT_ROOT/.tmp-bin/jq" -e ".$key" "$HANDOVER_FILE" > /dev/null 2>&1; then
                MISSING_KEYS+=("$key")
            fi
        done

        if [ ${#MISSING_KEYS[@]} -eq 0 ]; then
            echo -e "${GREEN}[VALID]${NC} agent-handover.json has required keys"
            ((COMPLIANT++)) || true
        else
            echo -e "${RED}[INVALID]${NC} agent-handover.json missing keys: ${MISSING_KEYS[*]}"
            echo "         Fix: Reinitialize with ./scripts/pm.sh init"
            ((DRIFT++)) || true
        fi
    fi
else
    echo -e "${YELLOW}[SKIP]${NC} jq not available - skipping JSON validation"
fi

echo ""

# Validation 4: Script permissions
echo "--- Script Permissions ---"

for script in "$PILOT_ROOT/scripts/"*.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "${GREEN}[EXEC]${NC} $(basename "$script")"
            ((COMPLIANT++)) || true
        else
            echo -e "${YELLOW}[NO-EXEC]${NC} $(basename "$script")"
            echo "         Fix: chmod +x $script"
            ((DRIFT++)) || true
        fi
    fi
done

echo ""

# Validation 5: .gitignore entries
echo "--- Gitignore Validation ---"

GITIGNORE="$PILOT_ROOT/.gitignore"
REQUIRED_IGNORES=(
    "artifacts/logs/"
    ".agent-lock"
    "*.log"
    ".env"
)

if [ -f "$GITIGNORE" ]; then
    for pattern in "${REQUIRED_IGNORES[@]}"; do
        if grep -q "$pattern" "$GITIGNORE" 2>/dev/null; then
            echo -e "${GREEN}[PRESENT]${NC} $pattern in .gitignore"
            ((COMPLIANT++)) || true
        else
            echo -e "${YELLOW}[MISSING]${NC} $pattern not in .gitignore"
            echo "         Fix: echo '$pattern' >> $GITIGNORE"
            ((DRIFT++)) || true
        fi
    done
else
    echo -e "${YELLOW}[MISSING]${NC} .gitignore file"
    echo "         Fix: Create .gitignore with required patterns"
    ((DRIFT++)) || true
fi

echo ""

# Summary
echo "=== Summary ==="
echo "Compliant: $COMPLIANT"
echo "Drift: $DRIFT"

if [ "$DRIFT" -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Configuration drift detected.${NC}"
    echo "Run the suggested 'Fix:' commands above to remediate."
    exit 1
else
    echo ""
    echo -e "${GREEN}Configuration is compliant.${NC}"
    exit 0
fi
