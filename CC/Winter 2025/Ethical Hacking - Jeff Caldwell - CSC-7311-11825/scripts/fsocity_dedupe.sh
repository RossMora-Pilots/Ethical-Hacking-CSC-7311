#!/bin/bash
# fsocity_dedupe.sh — Deduplicate the fsocity.dic wordlist for Mr. Robot CTF
#
# The TryHackMe Mr. Robot room provides fsocity.dic (~858,000 lines) with
# massive duplication. This script reduces it to ~11,450 unique lines —
# a 75× speedup for brute-force tools with zero coverage loss.
#
# Usage:  ./fsocity_dedupe.sh <input_wordlist> [output_file]
# Author: Ross Moravec
# Date:   2025-03-31 (Week 12 — Mr. Robot CTF)

set -euo pipefail

INPUT="${1:?Usage: $0 <input_wordlist> [output_file]}"
OUTPUT="${2:-${INPUT%.dic}_unique.dic}"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: file '$INPUT' not found." >&2
    exit 1
fi

BEFORE=$(wc -l < "$INPUT")
sort -u "$INPUT" > "$OUTPUT"
AFTER=$(wc -l < "$OUTPUT")
RATIO=$(echo "scale=1; $BEFORE / $AFTER" | bc)

echo "Deduplicated: $BEFORE → $AFTER lines (${RATIO}× reduction)"
echo "Output: $OUTPUT"
