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
- [x] Create CI workflows (markdownlint, gitleaks, lychee link-check, shellcheck)
- [ ] Run PM plumbing (`scripts/pm.sh run`) to generate artifacts _(Windows-only environment; deferred to Linux/CI)_
- [ ] Register pilot in portfolio index and render docs index

## Next

- [x] Add repo topics: `cybersecurity`, `ethical-hacking`, `penetration-testing`, `tryhackme`, `ctf`, `kali-linux`, `nmap`, `owasp` _(documented — apply via GitHub UI → Settings → Topics)_
- [x] Capture screenshots from source DOCX submissions and place in `screenshots/` with `wkNN_topic_index.png` naming (67 unique PNGs extracted)
- [x] Build auto-generated EVIDENCE_INDEX.md from screenshot inventory
- [x] Embed screenshots into CTF walkthrough documents (Pickle Rick: 25, Boiler: 21, Mr. Robot: 1)
- [x] Add link-check CI (lychee) and shellcheck validation for lab scripts
- [ ] Expand Week 2 / Week 7 / Week 9 gaps where material exists in transcripts
- [x] Extract student-authored scripts (fsocity_dedupe.sh, ctf_recon.sh, rot13_decode.py) to scripts/ directory
- [x] Add 3 portfolio helper scripts (nmap_parser.py, report_gen.sh, vuln_priority.py)
- [x] Embed screenshots into weekly reports (21 screenshots across 8 reports)
- [x] Add Mermaid diagrams to weekly reports (6 diagrams: wk04, wk05, wk06, wk08, wk10, wk11)
- [x] Convert ASCII attack paths to Mermaid in Week 12 and Week 13 weekly reports
- [x] Add Key Takeaway reflections to all 11 weekly reports
- [x] Standardize GitHub callouts across all weekly reports and reference docs (~27 new callouts)
- [x] Add cross-CTF comparison table to ctf-walkthroughs/README.md
- [x] Expand Metasploit section in tools.md (3 lines → 50 lines)
- [x] Expand tools.md with Burp Suite, Wireshark/tcpdump, tools awareness table, third-party attribution
- [x] Add "Is this legal?" authorization decision tree to legal-and-ethics.md
- [x] Add CASL (Canada's Anti-Spam Legislation) section to legal-and-ethics.md
- [x] Add career objective + contact info to top-level README
- [x] Add skill progression timeline and career roadmap to top-level README
- [x] Improve references/README.md with reading order and estimated times
- [x] Formalize Mr. Robot Steps 7-9 and add transparency note about screenshots
- [x] Enhance Mr. Robot textual evidence with reconstructed terminal output
- [x] Add CVE cross-references and CWE identifiers to all 3 CTF remediation tables
- [x] Add "Defensive Lens" callout sidebars to all 3 CTF walkthroughs
- [x] Add timing data to Boiler and Mr. Robot walkthroughs
- [x] Create MITRE ATT&CK consolidated technique reference page
- [x] Create professional pentest executive summary for Boiler CTF
- [x] Add OWASP testing decision tree (Mermaid) to owasp-top-10.md
- [x] Complete portfolio audit and remediation (documented in docs/PORTFOLIO_AUDIT_AND_REMEDIATION.md)
- [x] Complete employer-perspective audit and full 20-item remediation (docs/EMPLOYER_PORTFOLIO_AUDIT.md)

## Later

- [ ] Optional GitHub Pages landing with CTF writeup gallery _(documented as future enhancement — see audit W-16)_
- [x] Add architecture diagrams of lab network (Kali attacker + TryHackMe target) _(converted to Mermaid in course README)_
- [x] Record learning reflection and career-application narrative (Key Takeaway sections in all 11 weekly reports)
- [ ] Contribute CTF solutions upstream (personal blog, Medium) with canonical links here
- [x] Add MITRE ATT&CK technique mapping table per walkthrough _(consolidated reference at references/mitre-attack.md)_

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
