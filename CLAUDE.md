# Claude Code - Repo Instructions

Follow `AGENTS.md` as the canonical guide for this pilot.

## Pilot Purpose

Install and configure the Google Antigravity IDE environment, an agent-first development platform.

## Quick Start

```bash
# Validate environment
./scripts/health_check.sh

# Check current state
./scripts/pm.sh status

# Run PM automation
./scripts/pm.sh run

# Create handover (end of session)
./scripts/pm.sh handover

# Launch Mission Control
./bin/antigravity.sh --dashboard
```

## Antigravity Components

### IDE Binaries
- `./bin/antigravity.sh` - Main entry point
- `./bin/agent-manager.sh` - Manage and run agent personas
- `./bin/mission-control.sh` - System status dashboard

### Configuration
- `config/profiles/` - Agent persona definitions
- `config/connectivity/` - Service integration settings

## Key Entrypoints

- Environment check: `./scripts/health_check.sh`
- State management: `./scripts/pm.sh {status|parse|run|handover}`
- Self-healing: `./scripts/auto_heal.sh`
- Configuration validation: `./scripts/validate_config.sh`
- Service verification: `./scripts/check_connectivity.sh`

## Skills

Claude Code skills are located in `.claude/skills/`. Key skills:
- `pm-tools` - Project management automation
- `health-monitor` - Self-monitoring and healing

## Safety

- Never commit secrets (check `.gitignore`)
- Update `artifacts/state.json` after completing work
- Create handover record at end of session
- Run `health_check.sh` before and after major changes

## Coordination

This pilot uses shared state files for multi-agent coordination:
- `artifacts/state.json` - Current pilot state
- `artifacts/agent-handover.json` - Handover log
- `artifacts/.agent-lock` - Prevent concurrent mutations

See `docs/HANDOVER-PROTOCOL.md` for detailed coordination instructions.

<!-- BEGIN: cc-plugins -->
## Claude Code Plugins

Claude Code plugins are installed at **user scope** - they are already available in this
pilot; there is **no per-pilot install step**. They add skills, agents, slash commands,
and MCP tools you can use here directly.

- Themed index of what's installed: `D:\pilots\PLUGINS.md`
- List the live set anytime: `claude plugin list`  (details: `claude plugin details <name>`)
<!-- END: cc-plugins -->
