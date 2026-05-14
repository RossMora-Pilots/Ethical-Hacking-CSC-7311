#!/bin/bash
JQ="$PILOT_ROOT/.tmp-bin/jq"
set -euo pipefail

# daily_report.sh - Generate operational summary
# Creates human-readable status report

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PILOT_ROOT/artifacts/reports"
REPORT_FILE="$REPORT_DIR/daily-$(date +%Y-%m-%d).md"

# Ensure report directory exists
mkdir -p "$REPORT_DIR"

# Generate report
{
    echo "# Daily Report: $(basename "$PILOT_ROOT")"
    echo ""
    echo "**Generated:** $(date -Iseconds)"
    echo ""

    # Pilot Status
    echo "## Pilot Status"
    echo ""

    STATE_FILE="$PILOT_ROOT/artifacts/state.json"
    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
        echo "| Field | Value |"
        echo "|-------|-------|"
        echo "| Status | $("$PILOT_ROOT/.tmp-bin/jq" -r '.status // "unknown"' "$STATE_FILE") |"
        echo "| Phase | $("$PILOT_ROOT/.tmp-bin/jq" -r '.current_phase // "unknown"' "$STATE_FILE") |"
        echo "| Last Agent | $("$PILOT_ROOT/.tmp-bin/jq" -r '.last_agent // "none"' "$STATE_FILE") |"
        echo "| Last Updated | $("$PILOT_ROOT/.tmp-bin/jq" -r '.last_updated // "never"' "$STATE_FILE") |"
        echo ""

        echo "### Task Progress"
        echo ""
        TOTAL=$("$PILOT_ROOT/.tmp-bin/jq" -r '.tasks.total // 0' "$STATE_FILE")
        DONE=$("$PILOT_ROOT/.tmp-bin/jq" -r '.tasks.completed // 0' "$STATE_FILE")
        IN_PROGRESS=$("$PILOT_ROOT/.tmp-bin/jq" -r '.tasks.in_progress // 0' "$STATE_FILE")
        BLOCKED=$("$PILOT_ROOT/.tmp-bin/jq" -r '.tasks.blocked // 0' "$STATE_FILE")

        if [ "$TOTAL" -gt 0 ]; then
            PERCENT=$(( DONE * 100 / TOTAL ))
            echo "- Total: $TOTAL"
            echo "- Completed: $DONE ($PERCENT%)"
            echo "- In Progress: $IN_PROGRESS"
            echo "- Blocked: $BLOCKED"
        else
            echo "- No tasks tracked"
        fi
        echo ""
    else
        echo "*State file not available or jq not installed*"
        echo ""
    fi

    # Recent Handovers
    echo "## Recent Handovers (Last 5)"
    echo ""

    HANDOVER_FILE="$PILOT_ROOT/artifacts/agent-handover.json"
    if [ -f "$HANDOVER_FILE" ] && command -v jq &> /dev/null; then
        HANDOVER_COUNT=$("$PILOT_ROOT/.tmp-bin/jq" '.handovers | length' "$HANDOVER_FILE")

        if [ "$HANDOVER_COUNT" -gt 0 ]; then
            echo "| Time | Agent | Notes |"
            echo "|------|-------|-------|"
            "$PILOT_ROOT/.tmp-bin/jq" -r '.handovers | .[-5:] | reverse | .[] | "| \(.timestamp) | \(.from_agent) | \(.notes // "no notes") |"' "$HANDOVER_FILE"
        else
            echo "*No handovers recorded*"
        fi
        echo ""
    else
        echo "*Handover file not available*"
        echo ""
    fi

    # Health Status
    echo "## Health Status"
    echo ""

    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
        HEALTH_STATUS=$("$PILOT_ROOT/.tmp-bin/jq" -r '.health.status // "unknown"' "$STATE_FILE")
        LAST_CHECK=$("$PILOT_ROOT/.tmp-bin/jq" -r '.health.last_check // "never"' "$STATE_FILE")

        echo "- Status: $HEALTH_STATUS"
        echo "- Last Check: $LAST_CHECK"

        ISSUES=$("$PILOT_ROOT/.tmp-bin/jq" -r '.health.issues[]? // empty' "$STATE_FILE")
        if [ -n "$ISSUES" ]; then
            echo ""
            echo "### Issues"
            echo "$ISSUES" | while read -r issue; do
                echo "- $issue"
            done
        fi
        echo ""
    fi

    # Git Status
    echo "## Git Status"
    echo ""

    if [ -d "$PILOT_ROOT/.git" ]; then
        cd "$PILOT_ROOT"

        BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
        UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
        LAST_COMMIT=$(git log -1 --format="%h %s" 2>/dev/null || echo "no commits")

        echo "- Branch: $BRANCH"
        echo "- Uncommitted changes: $UNCOMMITTED"
        echo "- Last commit: $LAST_COMMIT"
    else
        echo "*Not a git repository*"
    fi
    echo ""

    # Action Items
    echo "## Action Items"
    echo ""

    ACTION_ITEMS=()

    # Check for stale lock
    LOCK_FILE="$PILOT_ROOT/artifacts/.agent-lock"
    if [ -f "$LOCK_FILE" ]; then
        LOCK_AGE=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
        if [ "$LOCK_AGE" -gt 1800 ]; then
            ACTION_ITEMS+=("Stale lock file detected (${LOCK_AGE}s old) - run auto_heal.sh")
        fi
    fi

    # Check for blocked tasks
    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
        BLOCKED=$("$PILOT_ROOT/.tmp-bin/jq" -r '.tasks.blocked // 0' "$STATE_FILE")
        if [ "$BLOCKED" -gt 0 ]; then
            ACTION_ITEMS+=("$BLOCKED blocked tasks require attention")
        fi
    fi

    # Check for uncommitted changes
    if [ -d "$PILOT_ROOT/.git" ]; then
        cd "$PILOT_ROOT"
        UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
        if [ "$UNCOMMITTED" -gt 10 ]; then
            ACTION_ITEMS+=("$UNCOMMITTED uncommitted changes - consider committing")
        fi
    fi

    if [ ${#ACTION_ITEMS[@]} -gt 0 ]; then
        for item in "${ACTION_ITEMS[@]}"; do
            echo "- [ ] $item"
        done
    else
        echo "*No action items*"
    fi
    echo ""

    # Footer
    echo "---"
    echo "*Report generated by daily_report.sh*"

} > "$REPORT_FILE"

echo "Daily report generated: $REPORT_FILE"

# Also output to stdout
cat "$REPORT_FILE"
