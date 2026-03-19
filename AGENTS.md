# AGENTS.md - 409-Ethical-Hacking

Marker: PROJECT_OK

## Overview

**Purpose:** ROADMAP — Ethical Hacking (CSC-7311) — Winter 2025 (Pilot 409)

**Scope:** This directory and all subdirectories.

---

## Pre-Flight Awareness Check

Before starting work on this pilot, start your session through the cross-pilot awareness wrapper:

```bash
/mnt/d/pilots/02001-Pilots-Aware-of-Other-Pilots/scripts/start_session.sh "$(basename $PWD)"
```

This runs the pre-flight awareness check, searches 300+ pilots for related work, flags potential duplicates, and writes a local awareness proof stamp used by supported workflows. For deeper searches, use:

```bash
/mnt/d/pilots/02001-Pilots-Aware-of-Other-Pilots/scripts/search_pilots.sh "topic or keyword"
```

---

## Quick Start

```bash
# 1. Check for related existing work
/mnt/d/pilots/02001-Pilots-Aware-of-Other-Pilots/scripts/start_session.sh "$(basename $PWD)"

# 2. Read ROADMAP.md for current tasks
cat ROADMAP.md
```

---

## Safety Rules

- Never commit secrets
- Update state files after completing work
- Create handover record when finishing
