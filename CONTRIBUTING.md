# Contributing & PM Conventions (Pilot 409)

- **Roadmap-first**: Edit `ROADMAP.md` (Now / Next / Later, Milestones, Runbook) before starting substantive work.
- **Evidence**: Run `scripts/pm.sh run` to regenerate `artifacts/roadmap.json`, `docs/sessions.md`, and `artifacts/state.json`.
- **Issues (optional)**: `scripts/pm.sh sync` (requires `gh` + `GH_TOKEN`).
- **Labels**: `roadmap`, `lane:now|next|later|unspecified`, `pilot:409-ethical-hacking`.
- **Secrets**: Never commit. Fetch via providers; scripts avoid `echo` of secrets; temp files use `umask 077`.
- **Lab boundaries**: All offensive content targets public, intentionally vulnerable lab environments (TryHackMe, CTF VMs). Do not point tooling at real-world infrastructure.
- **Student identifiers**: Student ID numbers have been redacted from filenames and content. The portfolio owner's name (Ross Moravec) is retained as authorship attribution.
