# Skill: Project Management Tools

## Description
Automates project management tasks for Codex Pilots, including roadmap parsing, artifact generation, and issue synchronization.

## Usage
Use this skill when you need to:
- Update the project status after completing work.
- Parse `ROADMAP.md` into machine-readable JSON.
- Sync roadmap items to GitHub Issues.

## Tools
### `pm.sh`
The primary entry point for PM operations.
```bash
./pm.sh <command>
```
- **Commands**:
    - `run`: Parses `ROADMAP.md`, updates `artifacts/roadmap.json`, indexes sessions, and auto-commits changes. Run this at the end of every session.
    - `sync`: Syncs roadmap items to GitHub Issues (requires `gh` CLI and `GH_TOKEN`).
    - `all`: Runs `run` and then pushes changes to the remote repository (`git push`).

## Examples
**End of Session Routine:**
```bash
# 1. Check status
git status

# 2. Run PM loop to update artifacts
./pm.sh run

# 3. (Optional) Push changes
PM_PUSH=1 ./pm.sh all
```
