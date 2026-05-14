## Overview

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

## Quick Start

```bash

# AGENTS.md - Universal Agent Instructions

Marker: PROJECT_OK

## Overview

This pilot follows the **LLM-Agnostic Blueprint** standard, enabling seamless cooperation between Claude Code CLI, Codex CLI, Gemini CLI, and GitHub Copilot CLI.

**Purpose:** Install and configure the Google Antigravity IDE environment, an agent-first development platform. This involves setting up the IDE binaries, configuration profiles, and connectivity modules.

**Scope:** This directory and all subdirectories.

**Components:**
- **IDE binaries:** Core execution scripts for Antigravity, Agent Manager, and Editor.
- **Configuration profiles:** User and project-specific settings.
- **Connectivity modules:** Integration with Gemini and other agent services.

**Key Artifacts:**
- `artifacts/state.json` — Pilot status and current phase
- `artifacts/agent-handover.json` — Async agent collaboration log
- `artifacts/metrics.json` — Operational performance metrics
- `artifacts/logs/` — Automated script execution logs

**Definition of Done:**
- [x] All roadmap items completed
- [x] Health checks pass (`./scripts/health_check.sh`)
- [x] State file updated (`artifacts/state.json`)
- [x] Handover record created (`artifacts/agent-handover.json`)
- [x] Mission Control dashboard functional
- [x] Agent Manager successfully running task simulations

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

### State Management

**Primary State File:** `artifacts/state.json`
- Updated by any agent after completing work
- Contains: pilot status, current phase, task counts, health status
- Must remain valid JSON at all times

**Handover File:** `artifacts/agent-handover.json`
- Append-only log of agent work sessions
- Each agent adds a handover record when finishing work
- Enables async collaboration without conflicts

**Lock Mechanism:** `artifacts/.agent-lock`
- Check before mutating state: `[ -f artifacts/.agent-lock ] && exit 1`
- Create lock: `echo "$(whoami):$(date -Iseconds)" > artifacts/.agent-lock`
- Release lock: `rm -f artifacts/.agent-lock`
- Stale lock detection: locks older than 30 minutes may be cleared by `auto_heal.sh`

### Task Flow

1. **Read** current state from `artifacts/state.json`
2. **Pull** tasks from `ROADMAP.md` (parsed to `artifacts/roadmap.json`)
3. **Acquire** lock before mutating files
4. **Execute** task (implement, fix, document)
5. **Update** state with task completion
6. **Release** lock
7. **Handover** - create handover record for next agent

### Handover Record Format

```json
{
  "from_agent": "claude-code|codex|gemini|copilot",
  "timestamp": "ISO-8601",
  "completed_tasks": ["task-id-1", "task-id-2"],
  "pending_tasks": ["task-id-3"],
  "notes": "Human-readable summary of work done",
  "blockers": [],
  "files_modified": ["path/to/file1", "path/to/file2"]
}
```

---

## Antigravity IDE Components

### IDE Binaries (`bin/`)
- `antigravity.sh`: Main entry point. Use `--dashboard` for Mission Control.
- `agent-manager.sh`: Persona management. Use `--run <persona> "<task>"` to simulate work.
- `editor.sh`: Workspace editor simulation.
- `mission-control.sh`: Real-time status dashboard.

### Configuration (`config/`)
- `profiles/*.json`: Agent persona definitions (Architect, Developer, Tester).
- `connectivity/gemini.json`: Service integration settings.

---

## CLI Entrypoints

| CLI Tool | Primary Config | Skills Directory |
|----------|---------------|------------------|
| Claude Code | `CLAUDE.md` | `.claude/skills/` |
| Codex CLI | (reads AGENTS.md) | `.codex/skills/` |
| Gemini CLI | `GEMINI.md` | `.gemini/skills/` |
| GitHub Copilot | `.github/copilot-instructions.md` | `.github/` |

All CLI tools should read this `AGENTS.md` as the canonical source of truth.

---

## Safety Rules

### NEVER Do
- Commit secrets (API keys, passwords, tokens)
- Run destructive commands without `--yes` or `--force` flags
- Modify files without acquiring lock first
- Skip validation before committing
- Echo secret values to console or logs

### ALWAYS Do
- Validate environment before work: `./scripts/health_check.sh`
- Update state after completing tasks
- Create handover record at end of session
- Use file locks for concurrent-safe operations
- Log all remediation actions

---

## Roadmap Integration

### ROADMAP.md Format
```markdown
# ROADMAP - Pilot Name

## Phase 1 - Foundation
- [x] Completed task
- [ ] Pending task
- [ ] Another pending task
```

### Parsing
`./scripts/pm.sh parse` converts ROADMAP.md to `artifacts/roadmap.json`.

