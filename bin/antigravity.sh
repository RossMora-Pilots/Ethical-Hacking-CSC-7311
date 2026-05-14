#!/bin/bash
echo "Google Antigravity IDE v0.1.0-preview"

case "${1:-}" in
    --dashboard)
        bash ./bin/mission-control.sh
        ;;
    *)
        echo "Mission Control: Starting agents..."
        bash ./bin/agent-manager.sh "${@:---status}"
        ;;
esac
