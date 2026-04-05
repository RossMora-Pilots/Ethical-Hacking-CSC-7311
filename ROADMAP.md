# ROADMAP — Ethical Hacking Portfolio (CSC-7311) — Winter 2025 (Pilot 409)

Public, employer-facing portfolio for the Ethical Hacking course taught by Jeff Caldwell at Cambrian College (Postgraduate Cybersecurity Certificate, Winter 2025 term). Mirrors academic structure under `CC/` with weekly writeups, CTF walkthroughs, tool references, and evidence indexes.

## Now
- [x] Establish course repo structure (README, docs, CC/, assignments/, screenshots/)
- [x] Align conventions with Pilot 008/009/010 (naming, labels, evidence)
- [x] Author employer-facing README with course overview, outcomes, evidence pointers
- [x] Document weekly learning from Week 1 through Week 13
- [x] Author full CTF walkthroughs: Pickle Rick (Midterm), Mr. Robot (Lab), Boiler CTF (Final)
- [x] Author OWASP Top 10 study companion
- [x] Publish tool reference (Nmap, Gobuster, Nikto, OpenVAS, JoomScan, Metasploit)
- [x] Add course syllabus summary and methodology pages
- [x] Add Mermaid attack-flow diagrams to all 3 CTF walkthroughs
- [x] Add Mermaid lifecycle diagram to methodology.md
- [x] Add Mermaid Kill Chain diagram to cyber-kill-chain.md
- [x] Add Mermaid tool selection decision tree to tools.md
- [x] Add OWASP lab coverage matrix to owasp-top-10.md
- [x] Add dedicated remediation tables (with CVSS) to all 3 CTF walkthroughs
- [x] Add MITRE ATT&CK mapping to Mr. Robot walkthrough
- [x] Add GitHub callouts (NOTE/TIP/WARNING/CAUTION) throughout portfolio
- [x] Add table of contents to CTF walkthroughs
- [x] Create Week 8 (midterm) weekly report
- [x] Create CI workflows (markdownlint, gitleaks)
- [ ] Run PM plumbing (`scripts/pm.sh run`) to generate artifacts
- [ ] Register pilot in portfolio index and render docs index

## Next
- [ ] Add repo topics: `cybersecurity`, `ethical-hacking`, `penetration-testing`, `tryhackme`, `ctf`, `kali-linux`, `nmap`, `owasp`
- [x] Capture screenshots from source DOCX submissions and place in `screenshots/` with `wkNN_topic_index.png` naming (67 unique PNGs extracted)
- [x] Build auto-generated EVIDENCE_INDEX.md from screenshot inventory
- [x] Embed screenshots into CTF walkthrough documents (Pickle Rick: 25, Boiler: 21, Mr. Robot: 1)
- [ ] Add link-check CI (lychee) and shellcheck validation for lab scripts
- [ ] Expand Week 2 / Week 7 / Week 9 gaps where material exists in transcripts
- [ ] Extract student-authored scripts (fsocity_dedupe.sh, ctf_recon.sh, rot13_decode.py) to scripts/ directory

## Later
- [ ] Optional GitHub Pages landing with CTF writeup gallery
- [ ] Add architecture diagrams of lab network (Kali attacker + TryHackMe target)
- [ ] Record learning reflection and career-application narrative
- [ ] Contribute CTF solutions upstream (personal blog, Medium) with canonical links here
- [ ] Add MITRE ATT&CK technique mapping table per walkthrough

## Milestones (Definition of Done)
- [x] Course repo structure finalized and documented
- [x] All 13 weeks of course content represented (weekly reports + CTF walkthroughs + references)
- [x] Midterm and Final walkthroughs published with full tool inventory and outcomes
- [ ] Evidence artifacts present (`roadmap.json`, `state.json`, `sessions.md`)
- [ ] CI green on push (gitleaks + markdownlint)
- [ ] Public repository live, branch protection enabled, secret scanning on

## Runbook
- PM loop: `scripts/pm.sh run` (auto-commit artifacts); `PM_PUSH=1 scripts/pm.sh all`
- Issues (optional): `scripts/pm.sh sync` (requires `gh` + `GH_TOKEN`)
- Roadmap parse only: `python scripts/roadmap/parse_roadmap.py ROADMAP.md --out artifacts/roadmap.json`
