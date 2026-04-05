#!/bin/bash
# ctf_recon.sh — Standardized initial reconnaissance for TryHackMe CTF rooms
#
# Runs Nmap (full-port), Gobuster (directory brute-force), and whatweb
# fingerprinting in sequence, saving all output to timestamped files.
# Designed as a repeatable "first 10 minutes" workflow for any new target.
#
# Usage:  ./ctf_recon.sh <target_ip>
# Author: Ross Moravec
# Date:   2025-03 (CSC-7311 course helper)

set -euo pipefail

TARGET="${1:?Usage: $0 <target_ip>}"
OUTDIR="recon_${TARGET}_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUTDIR"
echo "=== CTF Recon — Target: $TARGET ==="
echo "Output directory: $OUTDIR"
echo ""

# Phase 1: Nmap full-port scan with service/version detection + default scripts
echo "[*] Phase 1: Nmap full-port scan..."
sudo nmap -sC -sV -p- -oN "$OUTDIR/nmap_full.txt" -oX "$OUTDIR/nmap_full.xml" "$TARGET"
echo "[+] Nmap complete → $OUTDIR/nmap_full.txt"
echo ""

# Extract open ports for targeted follow-up
PORTS=$(grep -oP '^\d+/tcp\s+open' "$OUTDIR/nmap_full.txt" | cut -d/ -f1 | tr '\n' ',' | sed 's/,$//')
echo "[*] Open ports: ${PORTS:-none detected}"
echo ""

# Phase 2: Web fingerprinting (only if HTTP ports detected)
if echo "$PORTS" | grep -qE '(^|,)(80|443|8080|8443)(,|$)'; then
    echo "[*] Phase 2: whatweb fingerprinting..."
    whatweb "http://$TARGET" 2>/dev/null | tee "$OUTDIR/whatweb.txt"
    echo ""
fi

# Phase 3: Gobuster directory brute-force (only if HTTP detected)
if echo "$PORTS" | grep -qE '(^|,)(80|443|8080|8443)(,|$)'; then
    echo "[*] Phase 3: Gobuster directory brute-force..."
    gobuster dir \
        -u "http://$TARGET" \
        -w /usr/share/dirb/wordlists/common.txt \
        -x php,html,txt \
        -o "$OUTDIR/gobuster.txt" \
        --no-error \
        -q
    echo "[+] Gobuster complete → $OUTDIR/gobuster.txt"
    echo ""
fi

echo "=== Recon complete. Results in: $OUTDIR/ ==="
ls -la "$OUTDIR/"
