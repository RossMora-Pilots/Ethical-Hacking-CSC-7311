# ROADMAP — Ethical Hacking (CSC-7311) — Winter 2025 (Pilot 409)

This pilot creates a public, employer‑facing course portfolio repository for Ethical Hacking (CSC‑7311), Winter 2025, taught by Instructor Jeff Caldwell. It reuses the Pilot 009 template structure and conventions.

## Now
- [ ] Add course PDF to `docs/` and reference from README/ROADMAP
- [ ] Establish course repo structure (README, docs, assignments, artifacts)
- [ ] Align conventions with Pilot 008/009 (naming, labels, evidence)
- [ ] Run PM plumbing (parse roadmap → artifacts, sessions index)
- [ ] Register pilot in portfolio and render docs index

## Next
- [ ] Author README with course overview, outcomes, and evidence pointers
- [ ] Add repo topics/description; optional link‑check CI
- [ ] Organize sanitized assignments and screenshots under `assignments/` and `screenshots/`

## Later
- [ ] Optional GitHub Pages landing page
- [ ] Optional markdown linting and shell checks for scripts

## Milestones (Definition of Done)
- [ ] Course repo structure finalized and documented
- [ ] Evidence artifacts present (roadmap.json, state.json, sessions index)
- [ ] Labels normalized and Issues synced (optional); mirrors Pilot 008/009 conventions

## Runbook
- PM loop: `scripts/pm.sh run` (auto‑commit artifacts); `PM_PUSH=1 scripts/pm.sh all`
- Issues (optional): `scripts/pm.sh sync` (requires `gh` + `GH_TOKEN`)
