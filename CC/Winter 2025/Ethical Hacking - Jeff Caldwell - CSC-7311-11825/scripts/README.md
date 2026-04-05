# Scripts

Student-authored automation from CSC-7311 labs. When populated, includes shell scripts, Python helpers, and NSE scripts used during enumeration and exploitation.

## Inventory

Currently a placeholder — the course labs did not require bespoke automation beyond combining existing tools (Nmap, Gobuster, Hydra). Small helpers that emerged during the CTFs included:

| Script | Purpose | Source |
|---|---|---|
| `fsocity_dedupe.sh` | Deduplicate fsocity.dic for Mr. Robot WP brute-force | Week 12 |
| `ctf_recon.sh` | Standardized Nmap + Gobuster + whatweb one-shot | Personal helper |
| `rot13_decode.py` | Quick ROT13 round-trip for .info.txt files | Week 13 |

These will be added here as they are extracted from the source DOCX submissions.

## Conventions

- Shebang required (`#!/bin/bash`, `#!/usr/bin/env python3`)
- Header comment block: description, usage, author, date
- `set -euo pipefail` for bash scripts
- No hardcoded credentials or target IPs
- `bash -n` clean before commit

---

Back to [course README](../README.md).
