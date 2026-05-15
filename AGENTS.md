## Overview

**Purpose:** Ethical Hacking Portfolio (CSC-7311) — Winter 2025 (Pilot 409).

Purpose: Public portfolio repository for the Ethical Hacking course (CSC-7311) from the Postgraduate Cybersecurity Certificate at Cambrian College (Winter 2025, Instructor: Jeff Caldwell).
Scope: This directory and all subdirectories.

---

## Pre-Flight Awareness Check

Before starting work, run:

```bash
/mnt/d/pilots/02001-Pilots-Aware-of-Other-Pilots/scripts/start_session.sh "$(basename $PWD)"
```

This runs a pre-flight awareness check, searches the 300+ pilot corpus for duplicates, and writes a local proof stamp.

For deeper searches:

```bash
/mnt/d/pilots/02001-Pilots-Aware-of-Other-Pilots/scripts/search_pilots.sh "topic or keyword"
```

---

## Quick Start (Non-Interactive)

```bash
# 1. Validate environment
./scripts/health_check.sh

# 2. Check current state
./scripts/pm.sh status

# 3. Parse roadmap to JSON
./scripts/pm.sh parse

# 4. Run full PM loop (parse, update, optional commit)
./scripts/pm.sh run

# 5. Create handover record (end of session)
./scripts/pm.sh handover
```

---

## Agent Coordination Protocol

State and handover are tracked under `artifacts/`:

- `artifacts/state.json` — pilot status, phase, task counts; must remain valid JSON
- `artifacts/agent-handover.json` — append-only handover log
- `artifacts/.agent-lock` — file lock for concurrent-safe mutations (stale >30 min may be cleared by `auto_heal.sh`)

Handover record format:

```json
{
  "from_agent": "claude-code|codex|gemini|copilot",
  "timestamp": "ISO-8601",
  "completed_tasks": ["task-id-1"],
  "pending_tasks": ["task-id-2"],
  "notes": "Human-readable summary of work done",
  "blockers": [],
  "files_modified": ["path/to/file"]
}
```

---

## CLI Entrypoints

| CLI Tool | Primary Config | Skills Directory |
|----------|----------------|------------------|
| Claude Code | `CLAUDE.md` | `.claude/skills/` |
| Codex CLI | `AGENTS.md` (this file) | `.codex/skills/` |
| Gemini CLI | `GEMINI.md` | `.gemini/skills/` |
| GitHub Copilot | `.github/copilot-instructions.md` | `.github/` |

All CLI tools should treat this `AGENTS.md` as the canonical source of truth.

---

## Safety Rules

### NEVER
- Commit secrets (API keys, tokens, passwords)
- Run destructive commands without `--yes`/`--force` flags or explicit user authorization
- Modify shared state files without acquiring the lock first
- Echo secret values to console or logs

### ALWAYS
- Validate environment before work: `./scripts/health_check.sh`
- Update `artifacts/state.json` after completing tasks
- Create a handover record at end of session
- Use file locks for concurrent-safe operations
- Log remediation actions

---

## Roadmap Integration

`ROADMAP.md` uses markdown checkboxes:

```markdown
## Phase 1 - Foundation
- [x] Completed task
- [ ] Pending task
```

Run `./scripts/pm.sh parse` to convert ROADMAP.md to `artifacts/roadmap.json`.
