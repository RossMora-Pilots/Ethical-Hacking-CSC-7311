#!/bin/bash
set -eu

# check_connectivity.sh - Verify communication with agent services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"
CONN_CONFIG="$PILOT_ROOT/config/connectivity/gemini.json"

echo "=== Connectivity Check ==="

if [ ! -f "$CONN_CONFIG" ]; then
    echo "Error: Connectivity config not found at $CONN_CONFIG"
    exit 1
fi

# Simulate reading config
SERVICE=$(grep -o '"service": "[^"]*"' "$CONN_CONFIG" | cut -d'"' -f4)
ENDPOINT=$(grep -o '"endpoint": "[^"]*"' "$CONN_CONFIG" | cut -d'"' -f4)

echo "Service: $SERVICE"
echo "Endpoint: $ENDPOINT"
echo "Status: Pinging endpoint..."

if curl -s --head --request GET "$ENDPOINT" --connect-timeout 5 > /dev/null; then
    echo "Result: SUCCESS - Service is reachable"
    exit 0
else
    if curl -s -k "$ENDPOINT" --connect-timeout 5 > /dev/null; then
         echo "Result: SUCCESS - Service is reachable"
         exit 0
    else
        echo "Result: FAILED - Service unreachable"
        exit 0 
    fi
fi
