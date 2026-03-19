#!/usr/bin/env bash
set -euo pipefail
umask 077

HOST="${HOST:-192.168.0.38}"
USER="${USER:-synnasadmin}"
KEY="${KEY:-/mnt/e/01-Production/Services/backup-config/keys/synology_backup_key}"
QUIET=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [-h host] [-u user] [-k key] [-q]

Runs a non-interactive SSH connectivity check to the Synology NAS.
Defaults: HOST=$HOST USER=$USER KEY=$KEY

Examples:
  $(basename "$0")
  $(basename "$0") -h 192.168.0.38 -u synnasadmin -k /path/to/key

Env overrides: HOST, USER, KEY
EOF
}

while getopts ":h:u:k:qd" opt; do
  case "$opt" in
    h) HOST="$OPTARG" ;;
    u) USER="$OPTARG" ;;
    k) KEY="$OPTARG" ;;
    q) QUIET=1 ;;
    d) set -x ;;
    :) echo "Missing argument for -$OPTARG" >&2; usage; exit 2 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2 ;;
  esac
done

log() {
  [ "$QUIET" -eq 1 ] && return 0
  echo "$@" >&2
}

if [ ! -f "$KEY" ]; then
  echo "ERROR: Key not found: $KEY" >&2
  exit 2
fi

chmod 600 "$KEY" 2>/dev/null || true

FP=""
if [ -f "${KEY}.pub" ]; then
  FP=$(ssh-keygen -lf "${KEY}.pub" 2>/dev/null | awk '{print $2" ("$4")"}')
fi

log "Checking SSH to $USER@$HOST using $KEY${FP:+ | pub: $FP}"

set +e
OUT=$(ssh -i "$KEY" \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o PasswordAuthentication=no \
  -o PubkeyAuthentication=yes \
  -o BatchMode=yes \
  -o ConnectTimeout=8 \
  "$USER@$HOST" 'echo __SSH_OK__ && whoami && hostname && date -Iseconds' 2>&1)
RC=$?
set -e

if [ $RC -eq 0 ] && echo "$OUT" | grep -q "__SSH_OK__"; then
  echo "SSH:OK"
  echo "$OUT" | sed -n '1,4p'
  exit 0
else
  echo "SSH:FAIL ($RC)" >&2
  echo "$OUT" >&2
  exit $RC
fi

