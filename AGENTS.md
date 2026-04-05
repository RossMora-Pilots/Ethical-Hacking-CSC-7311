# AGENTS.md — 409-Ethical-Hacking

Marker: PROJECT_OK

## Overview
Purpose: Public portfolio repository for the Ethical Hacking course (CSC-7311) from the Postgraduate Cybersecurity Certificate at Cambrian College (Winter 2025, Instructor: Jeff Caldwell).
Scope: This directory and all subdirectories.

---

## Pre-Flight Awareness Check
Before starting work, run:

```
/mnt/d/pilots/02001-Pilots-Aware-of-Other-Pilots/scripts/start_session.sh "$(basename $PWD)"
```

This runs a pre-flight awareness check, searches the 300+ pilot corpus for duplicates, and writes a local proof stamp.

For deeper searches:

```
/mnt/d/pilots/02001-Pilots-Aware-of-Other-Pilots/scripts/search_pilots.sh "topic or keyword"
```

---

## Quick Start

```bash
# 1. Check for related existing work across pilots
/mnt/d/pilots/02001-Pilots-Aware-of-Other-Pilots/scripts/start_session.sh "$(basename $PWD)"

# 2. Read ROADMAP.md for current tasks
cat ROADMAP.md

# 3. Run PM loop to regenerate artifacts
scripts/pm.sh run
```

---

## Safety Rules
- Never commit secrets, student IDs, or personally identifying information other than the portfolio owner's name.
- Never commit raw recordings of classroom sessions or other students' voices.
- Never publish working exploits targeted at real-world infrastructure — all content must remain scoped to intentionally vulnerable lab targets (TryHackMe rooms, CTF VMs).
- Update state files after completing work.
- Create a handover record when finishing a session.
- Passwords and flags that appear here are from public TryHackMe rooms (Pickle Rick, Mr. Robot, Boiler CTF) and are therefore already published; they remain in writeups for pedagogical accuracy.
