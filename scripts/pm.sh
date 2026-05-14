#!/bin/bash
set -euo pipefail

# pm.sh - Project Management Automation for LLM-Agnostic Pilots
# Supports: Claude Code, Codex CLI, Gemini CLI, GitHub Copilot

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"
JQ="$PILOT_ROOT/.tmp-bin/jq"
if [ ! -f "$JQ" ]; then
    if command -v jq &> /dev/null; then
        JQ="jq"
    fi
fi
ARTIFACTS_DIR="$PILOT_ROOT/artifacts"
STATE_FILE="$ARTIFACTS_DIR/state.json"
HANDOVER_FILE="$ARTIFACTS_DIR/agent-handover.json"
ROADMAP_FILE="$PILOT_ROOT/ROADMAP.md"
ROADMAP_JSON="$ARTIFACTS_DIR/roadmap.json"
LOCK_FILE="$ARTIFACTS_DIR/.agent-lock"
LOG_DIR="$ARTIFACTS_DIR/logs"

# Ensure directories exist
mkdir -p "$ARTIFACTS_DIR" "$LOG_DIR"

# Detect agent (can be overridden via AGENT_ID env var)
detect_agent() {
    if [ -n "${AGENT_ID:-}" ]; then
        echo "$AGENT_ID"
    elif [ -n "${CLAUDE_CODE:-}" ] || [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        echo "claude-code"
    elif [ -n "${OPENAI_API_KEY:-}" ]; then
        echo "codex"
    elif [ -n "${GOOGLE_API_KEY:-}" ] || [ -n "${GEMINI_API_KEY:-}" ]; then
        echo "gemini"
    elif [ -n "${GITHUB_TOKEN:-}" ]; then
        echo "copilot"
    else
        echo "manual"
    fi
}

AGENT_ID=$(detect_agent)

# Logging
log() {
    local level="$1"
    shift
    echo "[$(date -Iseconds)] [$level] $*" | tee -a "$LOG_DIR/pm.log"
}

# Check if "$JQ" is available
require_jq() {
    if ! command -v "$JQ" &> /dev/null && [ ! -f "$JQ" ]; then
        log "ERROR" ""$JQ" is required but not installed"
        exit 1
    fi
}

# Initialize state files
cmd_init() {
    log "INFO" "Initializing state files"

    local pilot_name
    pilot_name=$(basename "$PILOT_ROOT")
    local timestamp
    timestamp=$(date -Iseconds)

    # Create state.json
    cat > "$STATE_FILE" << EOF
{
  "pilot": "$pilot_name",
  "version": "0.1.0",
  "status": "not_started",
  "current_phase": "Phase 0 - Bootstrap",
  "last_agent": null,
  "last_updated": "$timestamp",
  "tasks": {
    "total": 0,
    "completed": 0,
    "in_progress": 0,
    "blocked": 0
  },
  "health": {
    "last_check": null,
    "status": "unknown",
    "issues": []
  },
  "metadata": {
    "created": "$timestamp",
    "blueprint_version": "1.0.0",
    "supported_agents": ["claude-code", "codex", "gemini", "copilot"]
  }
}
EOF

    # Create agent-handover.json
    cat > "$HANDOVER_FILE" << EOF
{
  "schema_version": "1.0.0",
  "pilot": "$pilot_name",
  "handovers": []
}
EOF

    log "INFO" "State files initialized"
}

# Parse ROADMAP.md to JSON
cmd_parse() {
    log "INFO" "Parsing ROADMAP.md to JSON"
    require_jq

    if [ ! -f "$ROADMAP_FILE" ]; then
        log "ERROR" "ROADMAP.md not found at $ROADMAP_FILE"
        exit 1
    fi

    local total=0
    local done=0
    local sections="{}"
    local current_section=""

    while IFS= read -r line; do
        # Detect section headers
        if [[ "$line" =~ ^##[[:space:]]+(.+)$ ]]; then
            current_section="${BASH_REMATCH[1]}"
        # Detect completed tasks
        elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\[x\][[:space:]]+(.+)$ ]]; then
            ((total++)) || true
            ((done++)) || true
        # Detect pending tasks
        elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\[[[:space:]]\][[:space:]]+(.+)$ ]]; then
            ((total++)) || true
        fi
    done < "$ROADMAP_FILE"

    cat > "$ROADMAP_JSON" << EOF
{
  "path": "$ROADMAP_FILE",
  "parsed_at": "$(date -Iseconds)",
  "items_total": $total,
  "items_done": $done,
  "items_pending": $((total - done))
}
EOF

    log "INFO" "Parsed $total items ($done done, $((total - done)) pending)"

    # Update state.json with task counts
    if [ -f "$STATE_FILE" ]; then
        local tmp_file
        tmp_file=$(mktemp)
        "$JQ" --argjson total "$total" --argjson done "$done" \
            '.tasks.total = $total | .tasks.completed = $done | .last_updated = (now | todate)' \
            < "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
    fi
}

# Show current status
cmd_status() {
    require_jq

    echo "=== Pilot Status ==="
    echo ""

    if [ -f "$STATE_FILE" ]; then
        echo "State:"
        "$JQ" -r '"  Pilot: \(.pilot)\n  Status: \(.status)\n  Phase: \(.current_phase)\n  Last Agent: \(.last_agent // "none")\n  Tasks: \(.tasks.completed)/\(.tasks.total) done"' < "$STATE_FILE"
    else
        echo "  No state file found. Run: ./scripts/pm.sh init"
    fi

    echo ""

    if [ -f "$ROADMAP_JSON" ]; then
        echo "Roadmap:"
        "$JQ" -r '"  Total: \(.items_total)\n  Done: \(.items_done)\n  Pending: \(.items_pending)"' < "$ROADMAP_JSON"
    else
        echo "  No roadmap.json. Run: ./scripts/pm.sh parse"
    fi

    echo ""

    if [ -f "$HANDOVER_FILE" ]; then
        local count
        count=$("$JQ" '.handovers | length' < "$HANDOVER_FILE" | tr -d '\r')
        echo "Handovers: $count total"
        if [ "$count" -gt 0 ]; then
            echo "Last handover:"
            "$JQ" -r '.handovers[-1] | "  From: \(.from_agent)\n  Time: \(.timestamp)\n  Notes: \(.notes)"' < "$HANDOVER_FILE"
        fi
    fi

    echo ""

    if [ -f "$LOCK_FILE" ]; then
        echo "Lock: ACTIVE"
        cat "$LOCK_FILE"
    else
        echo "Lock: None"
    fi
}

# Full PM run (parse + update state)
cmd_run() {
    log "INFO" "Running full PM loop"

    # Parse roadmap
    cmd_parse

    # Update state
    if [ -f "$STATE_FILE" ]; then
        require_jq
        local tmp_file
        tmp_file=$(mktemp)
        "$JQ" --arg agent "$AGENT_ID" \
            '.last_agent = $agent | .last_updated = (now | todate) | .status = (if .tasks.completed == .tasks.total and .tasks.total > 0 then "completed" elif .tasks.completed > 0 then "in_progress" else .status end)' \
            < "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
    fi

    log "INFO" "PM loop complete"
    cmd_status
}

# Create handover record
cmd_handover() {
    log "INFO" "Creating handover record"
    require_jq

    if [ ! -f "$HANDOVER_FILE" ]; then
        log "ERROR" "Handover file not found. Run: ./scripts/pm.sh init"
        exit 1
    fi

    # Prompt for notes if interactive, otherwise use default
    local notes="${HANDOVER_NOTES:-Session completed by $AGENT_ID}"
    local completed="${HANDOVER_COMPLETED:-[]}"
    local pending="${HANDOVER_PENDING:-[]}"
    local files="${HANDOVER_FILES:-[]}"
    local next_steps="${HANDOVER_NEXT:-[]}"

    local uuid
    uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || date +%s%N | sha256sum | head -c 36)

    local tmp_file
    tmp_file=$(mktemp)

    "$JQ" --arg id "$uuid" \
       --arg agent "$AGENT_ID" \
       --arg ts "$(date -Iseconds)" \
       --arg notes "$notes" \
       --argjson completed "$completed" \
       --argjson pending "$pending" \
       --argjson files "$files" \
       --argjson next "$next_steps" \
       '.handovers += [{
          "id": $id,
          "from_agent": $agent,
          "to_agent": "any",
          "timestamp": $ts,
          "completed_tasks": $completed,
          "pending_tasks": $pending,
          "notes": $notes,
          "blockers": [],
          "files_modified": $files,
          "next_steps": $next
        }]' < "$HANDOVER_FILE" > "$tmp_file" && mv "$tmp_file" "$HANDOVER_FILE"

    log "INFO" "Handover record created"

    # Remove lock if exists
    if [ -f "$LOCK_FILE" ]; then
        rm -f "$LOCK_FILE"
        log "INFO" "Lock released"
    fi
}

# Acquire lock
cmd_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_age
        lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
        if [ "$lock_age" -gt 1800 ]; then
            log "WARN" "Stale lock detected (${lock_age}s old). Removing."
            rm -f "$LOCK_FILE"
        else
            log "ERROR" "Lock already held:"
            cat "$LOCK_FILE"
            exit 1
        fi
    fi

    echo "$AGENT_ID:$(hostname):$(date -Iseconds)" > "$LOCK_FILE"
    log "INFO" "Lock acquired"
}

# Release lock
cmd_unlock() {
    if [ -f "$LOCK_FILE" ]; then
        rm -f "$LOCK_FILE"
        log "INFO" "Lock released"
    else
        log "WARN" "No lock to release"
    fi
}

# Show help
cmd_help() {
    cat << EOF
pm.sh - Project Management for LLM-Agnostic Pilots

Usage: ./scripts/pm.sh <command>

Commands:
  init      Initialize state files (fresh start)
  parse     Parse ROADMAP.md to artifacts/roadmap.json
  status    Show current pilot status
  run       Full PM loop (parse + update state)
  handover  Create handover record for next agent
  lock      Acquire concurrency lock
  unlock    Release concurrency lock
  help      Show this help

Environment Variables:
  AGENT_ID          Override agent identifier
  HANDOVER_NOTES    Notes for handover record
  HANDOVER_COMPLETED  JSON array of completed task IDs
  HANDOVER_PENDING    JSON array of pending task IDs
  HANDOVER_FILES      JSON array of modified files
  HANDOVER_NEXT       JSON array of suggested next steps

Examples:
  ./scripts/pm.sh init
  ./scripts/pm.sh parse
  ./scripts/pm.sh status
  AGENT_ID=claude-code ./scripts/pm.sh run
  HANDOVER_NOTES="Completed Phase 1" ./scripts/pm.sh handover
EOF
}

# Main
case "${1:-help}" in
    init)     cmd_init ;;
    parse)    cmd_parse ;;
    status)   cmd_status ;;
    run)      cmd_run ;;
    handover) cmd_handover ;;
    lock)     cmd_lock ;;
    unlock)   cmd_unlock ;;
    help)     cmd_help ;;
    *)
        log "ERROR" "Unknown command: $1"
        cmd_help
        exit 1
        ;;
esac
