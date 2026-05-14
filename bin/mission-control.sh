#!/bin/bash
set -eu

# mission-control.sh - Antigravity IDE Dashboard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Google Antigravity MISSION CONTROL ==="
echo "Pilot: $(basename "$PILOT_ROOT")"
echo "Time: $(date -Iseconds)"
echo ""

# 1. Environment Health
echo "--- Environment Health ---"
if bash "$PILOT_ROOT/scripts/health_check.sh" > /dev/null; then
    echo "Status: HEALTHY"
else
    echo "Status: UNHEALTHY (run health_check.sh for details)"
fi

# 2. Agent Status
echo ""
echo "--- Agent Status ---"
bash "$PILOT_ROOT/bin/agent-manager.sh" --status | sed 's/^/  /'

# 3. Connectivity
echo ""
echo "--- Service Connectivity ---"
bash "$PILOT_ROOT/scripts/check_connectivity.sh" | grep "Result" | sed 's/^/  /'

# 4. Recent Metrics
echo ""
echo "--- Recent Activity (Metrics) ---"
if [ -f "$PILOT_ROOT/artifacts/metrics.json" ]; then
    # Use JQ for robust parsing if available
    JQ="$PILOT_ROOT/.tmp-bin/jq"
    if [ ! -f "$JQ" ]; then JQ="jq"; fi

    tail -n 5 "$PILOT_ROOT/artifacts/metrics.json" | while read -r line; do
        if "$JQ" --version &>/dev/null; then
            TASK=$(echo "$line" | "$JQ" -r '.task // "unknown"' | tr -d '\r')
            PERSONA=$(echo "$line" | "$JQ" -r '.persona // "unknown"' | tr -d '\r')
            echo "  - $TASK ($PERSONA)"
        else
            echo "  - $(echo "$line" | grep -o '"task": "[^"]*"' | cut -d'"' -f4) ($(echo "$line" | grep -o '"persona": "[^"]*"' | cut -d'"' -f4))"
        fi
    done
else
    echo "  No activity logged."
fi

echo ""
echo "=== Dashboard End ==="
