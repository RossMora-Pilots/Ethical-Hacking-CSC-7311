#!/usr/bin/env bash
# Verify a provider secret matches a source file by hash-only comparison.
# Usage: verify_match.sh <provider> <name_or_path> <src_file>

set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <provider> <name_or_path> <src_file>" >&2
  exit 2
fi

provider="$1"
name_or_path="$2"
src="$3"

if [ ! -f "$src" ]; then
  echo "SRC_MISSING:$src" >&2
  exit 1
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
retriever="$HERE/retrieve_to.sh"
[ -x "$retriever" ] || { echo "ERR: retrieve_to.sh not found" >&2; exit 1; }

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

"$retriever" "$provider" "$name_or_path" "$tmp" >/dev/null 2>&1 || { echo "VERIFY:RETRIEVE_FAIL"; exit 1; }

src_hash=$(sha256sum "$src" | awk '{print $1}')
tmp_hash=$(sha256sum "$tmp" | awk '{print $1}')

if [ "$src_hash" = "$tmp_hash" ]; then
  echo "VERIFY:MATCH:$provider:$name_or_path:$src_hash"
else
  echo "VERIFY:DIFF:$provider:$name_or_path:$src_hash!=$tmp_hash"
fi

