#!/bin/bash
JQ="$PILOT_ROOT/.tmp-bin/jq"
set -euo pipefail

# monitor_daemon.sh - Continuous monitoring loop
# Runs health checks on interval and triggers auto-healing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PILOT_ROOT/artifacts/logs"
LOG_FILE="$LOG_DIR/monitor.log"
PID_FILE="$LOG_DIR/monitor.pid"

# Configuration
CHECK_INTERVAL="${CHECK_INTERVAL:-300}"  # 5 minutes default
AUTO_HEAL="${AUTO_HEAL:-true}"
MAX_HEAL_ATTEMPTS="${MAX_HEAL_ATTEMPTS:-3}"

# Ensure directories
mkdir -p "$LOG_DIR"

# Logging
log() {
    local level="$1"
    shift
    echo "[$(date -Iseconds)] [$level] $*" | tee -a "$LOG_FILE"
}

# Handle signals
cleanup() {
    log "INFO" "Shutting down monitor daemon"
    rm -f "$PID_FILE"
    exit 0
}
trap cleanup SIGINT SIGTERM

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Monitor daemon already running (PID: $OLD_PID)"
        echo "Stop it first: kill $OLD_PID"
        exit 1
    else
        rm -f "$PID_FILE"
    fi
fi

# Start daemon
case "${1:-start}" in
    start)
        echo "Starting monitor daemon..."
        echo "  Check interval: ${CHECK_INTERVAL}s"
        echo "  Auto-heal: $AUTO_HEAL"
        echo "  Log file: $LOG_FILE"
        echo "  PID file: $PID_FILE"
        echo ""
        echo "Press Ctrl+C to stop or run in background:"
        echo "  nohup ./scripts/monitor_daemon.sh &"
        echo ""

        # Write PID
        echo $$ > "$PID_FILE"
        log "INFO" "Monitor daemon started (PID: $$)"

        HEAL_ATTEMPTS=0

        while true; do
            log "INFO" "Running health check..."

            # Run health check
            if "$SCRIPT_DIR/health_check.sh" > "$LOG_DIR/health_check_latest.log" 2>&1; then
                log "INFO" "Health check passed"
                HEAL_ATTEMPTS=0

                # Update state with health status
                STATE_FILE="$PILOT_ROOT/artifacts/state.json"
                if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
                    TMP_FILE=$(mktemp)
                    jq --arg ts "$(date -Iseconds)" \
                       '.health.last_check = $ts | .health.status = "healthy" | .health.issues = []' \
                       "$STATE_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"
                fi
            else
                log "WARN" "Health check failed"

                # Attempt auto-heal if enabled
                if [ "$AUTO_HEAL" = "true" ] && [ "$HEAL_ATTEMPTS" -lt "$MAX_HEAL_ATTEMPTS" ]; then
                    log "INFO" "Attempting auto-heal (attempt $((HEAL_ATTEMPTS + 1))/$MAX_HEAL_ATTEMPTS)..."
                    ((HEAL_ATTEMPTS++)) || true

                    if "$SCRIPT_DIR/auto_heal.sh" > "$LOG_DIR/auto_heal_latest.log" 2>&1; then
                        log "INFO" "Auto-heal completed"
                    else
                        log "ERROR" "Auto-heal failed"
                    fi
                elif [ "$HEAL_ATTEMPTS" -ge "$MAX_HEAL_ATTEMPTS" ]; then
                    log "ERROR" "Max heal attempts reached - manual intervention required"

                    # Update state with unhealthy status
                    STATE_FILE="$PILOT_ROOT/artifacts/state.json"
                    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
                        TMP_FILE=$(mktemp)
                        jq --arg ts "$(date -Iseconds)" \
                           '.health.last_check = $ts | .health.status = "unhealthy" | .health.issues += ["Auto-heal max attempts reached"]' \
                           "$STATE_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"
                    fi
                fi
            fi

            log "INFO" "Sleeping for ${CHECK_INTERVAL}s..."
            sleep "$CHECK_INTERVAL"
        done
        ;;

    stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                kill "$PID"
                rm -f "$PID_FILE"
                echo "Monitor daemon stopped (PID: $PID)"
            else
                rm -f "$PID_FILE"
                echo "Monitor daemon not running (stale PID file removed)"
            fi
        else
            echo "Monitor daemon not running"
        fi
        ;;

    status)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                echo "Monitor daemon running (PID: $PID)"

                # Show recent log entries
                echo ""
                echo "Recent log entries:"
                tail -10 "$LOG_FILE" 2>/dev/null || echo "  No logs available"
            else
                echo "Monitor daemon not running (stale PID file)"
            fi
        else
            echo "Monitor daemon not running"
        fi
        ;;

    *)
        echo "Usage: $0 {start|stop|status}"
        echo ""
        echo "Environment variables:"
        echo "  CHECK_INTERVAL   Seconds between checks (default: 300)"
        echo "  AUTO_HEAL        Enable auto-healing (default: true)"
        echo "  MAX_HEAL_ATTEMPTS  Max healing attempts (default: 3)"
        exit 1
        ;;
esac
