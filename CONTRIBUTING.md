# Contributing & PM Conventions (Pilot Template)

- Roadmap‑first: Edit `ROADMAP.md` (Now/Next/Later, Milestones, Runbook)
- Evidence: `scripts/pm.sh run` → `artifacts/roadmap.json`, `docs/sessions.md`, `artifacts/state.json`
- Issues (optional): `scripts/pm.sh sync` (requires `gh` + `GH_TOKEN`)
- Labels: `roadmap`, `lane:now|next|later|unspecified`, `pilot:<slug>`
- Secrets: never commit. Fetch via providers; scripts avoid echo; temp files use umask 077.
