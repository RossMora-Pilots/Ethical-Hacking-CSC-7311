# Scripts

Student-authored automation from CSC-7311 labs. Includes shell scripts and Python helpers used during CTF enumeration and exploitation.

## Inventory

| Script | Purpose | Source | Language |
|---|---|---|---|
| [`fsocity_dedupe.sh`](fsocity_dedupe.sh) | Deduplicate fsocity.dic for Mr. Robot WP brute-force (858k → 11.5k lines) | Week 12 | Bash |
| [`ctf_recon.sh`](ctf_recon.sh) | Standardized Nmap + Gobuster + whatweb initial recon one-shot | Personal helper | Bash |
| [`rot13_decode.py`](rot13_decode.py) | Quick ROT13 round-trip for CTF hint files (.info.txt on Boiler) | Week 13 | Python 3 |

## Conventions

- Shebang required (`#!/bin/bash`, `#!/usr/bin/env python3`)
- Header comment block: description, usage, author, date
- `set -euo pipefail` for bash scripts
- No hardcoded credentials or target IPs
- `bash -n` clean before commit

---

Back to [course README](../README.md).
