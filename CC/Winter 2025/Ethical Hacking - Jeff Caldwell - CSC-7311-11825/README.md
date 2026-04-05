# Ethical Hacking — CSC-7311 — Winter 2025

> Cambrian College · Postgraduate Cybersecurity Certificate · Instructor: **Jeff Caldwell**

A 13-week offensive security course taught Monday evenings (17:30–20:30) in Room 1215 with a Zoom broadcast option. Graded via six labs, four activities, four quizzes, a practical midterm CTF, and a practical final CTF. No textbook — the course used TryHackMe rooms, Moodle-hosted slide decks, and live in-class demonstrations (Wi-Fi Pineapple, Flipper Zero).

---

## Start Here

| I want to... | Open this |
|---|---|
| Understand the course shape quickly | [course-outline.md](course-outline.md) |
| See what was covered each week | [weekly-reports/](weekly-reports/) |
| Read the midterm CTF walkthrough | [ctf-walkthroughs/midterm-pickle-rick.md](ctf-walkthroughs/midterm-pickle-rick.md) |
| Read the final CTF walkthrough | [ctf-walkthroughs/final-boiler-ctf.md](ctf-walkthroughs/final-boiler-ctf.md) |
| Study OWASP Top 10 concepts | [references/owasp-top-10.md](references/owasp-top-10.md) |
| Review the pentest methodology | [references/methodology.md](references/methodology.md) |
| Understand the legal framework | [references/legal-and-ethics.md](references/legal-and-ethics.md) |
| See the tool inventory | [references/tools.md](references/tools.md) |
| Review all evidence screenshots | [EVIDENCE_INDEX.md](EVIDENCE_INDEX.md) |

---

## Course at a Glance

- **Code:** CSC-7311-11825
- **Instructor:** Jeff Caldwell (Professor, Cambrian College; 3+ years teaching cybersecurity, settings, computer engineering, IT business analysis, mobile app development)
- **Mode:** In-person with live Zoom option
- **Platform:** TryHackMe (free tier) + Kali Linux on VirtualBox
- **Submission platform:** Moodle
- **Schedule:** Weekly Mondays, 17:30–20:30, Jan 13 – April 14, 2025
- **Prerequisites assumed:** working knowledge of Linux system administration, Windows Server administration, and networking fundamentals (TCP/IP, common ports, protocol stacks)

### Grading Structure

| Component | Weight | Count |
|---|---|---|
| Small labs / activities | graded individually | 6 |
| Large labs (multi-part) | graded individually | 4 |
| Quizzes (multiple choice + short answer, open-book) | graded individually | 4 |
| **Midterm (practical CTF)** | — | 1 (Pickle Rick) |
| **Final (practical CTF)** | — | 1 (Boiler CTF) |

All assignments open-book. Quizzes open for the full day of release; midterm/final invigilated during class.

---

## Weekly Reports

| Week | Date | Topic | Deliverable | Link |
|---|---|---|---|---|
| 1 | 2025-01-13 | Course orientation, ethics, methodology, lab setup | Reading + environment ready | [week-01](weekly-reports/week-01-course-introduction.md) |
| 2 | 2025-01-20 | Network protocol refresher, footprinting, social engineering | Discussion | [week-02](weekly-reports/week-02-network-protocols-and-footprinting.md) |
| 3 | 2025-01-20 | Cyber Kill Chain Parts 1 & 2 | Assignment | [week-03](weekly-reports/week-03-cyber-kill-chain.md) |
| 4 | 2025-01-27 | Module 03: Further Nmap, OSI, Recon, Web App Security Intro | Lab 3 | [week-04](weekly-reports/week-04-nmap-osi-web-app-security.md) |
| 5 | 2025-02-03 | Enumeration, Brute Force, OpenVAS | Lab | [week-05](weekly-reports/week-05-enumeration-brute-force-openvas.md) |
| 6 | 2025-02-10 | Network Services Parts 1-2-3 (two-session week) | Lab | [week-06](weekly-reports/week-06-network-services.md) |
| 8 | 2025-03-03 | **MIDTERM — TryHackMe: Pickle Rick** | Practical CTF | [midterm walkthrough](ctf-walkthroughs/midterm-pickle-rick.md) |
| 10 | ~2025-03-17 | Phishing Analysis (Part 1) + Phishing in Action (Part 2) | Lab | [week-10](weekly-reports/week-10-phishing.md) |
| 11 | 2025-03-24 | Live Host Scanning (Nmap) + Wireless Hacking 101 | Dual lab | [week-11](weekly-reports/week-11-live-host-scanning-wireless.md) |
| 12 | 2025-03-31 | Mr. Robot CTF Lab (WordPress) | Lab | [week-12 + walkthrough](ctf-walkthroughs/mr-robot-ctf.md) |
| 13 | 2025-04-14 | **FINAL — TryHackMe: Boiler CTF + OWASP Top 10** | Practical CTF + companion | [final walkthrough](ctf-walkthroughs/final-boiler-ctf.md) |

Weeks 7 (reading week) and 9 (instructor catch-up) had no graded deliverables.

---

## Major Artifacts

### CTF Walkthroughs (full step-by-step)

- **[Pickle Rick — Midterm](ctf-walkthroughs/midterm-pickle-rick.md)** (web exploitation, command injection, sudo privesc) — 106 paragraphs, 25 screenshots in source
- **[Mr. Robot CTF](ctf-walkthroughs/mr-robot-ctf.md)** (WordPress enumeration, exploitation)
- **[Boiler CTF — Final](ctf-walkthroughs/final-boiler-ctf.md)** (FTP anon, Joomla, Sar2HTML RCE, SSH, SUID `find` privesc) — 163 paragraphs, 21 screenshots

### Reference Material (study companions)

- **[OWASP Top 10](references/owasp-top-10.md)** — threat catalog with examples and mitigations
- **[Methodology](references/methodology.md)** — full pentest lifecycle (recon → reporting)
- **[Cyber Kill Chain](references/cyber-kill-chain.md)** — Lockheed Martin 7-step model
- **[Legal & Ethics](references/legal-and-ethics.md)** — Canadian Criminal Code, PIPEDA, NDAs, disclosure
- **[Tools](references/tools.md)** — inventory of every tool used, with canonical commands

---

## Skills Demonstrated

### Reconnaissance & Enumeration

`nmap -sC -sV -p-` · `nmap -A -T4 -p-` · Nmap NSE scripts · `gobuster dir` with `dirb/common.txt` and `directory-list-2.3-medium.txt` · Nikto · Wappalyzer-style fingerprinting · anonymous FTP banner grabbing

### Vulnerability Assessment

OpenVAS/Greenbone authenticated scans · JoomScan against Joomla 3.9.10 · CVE research workflow · Sar2HTML 3.2.1 RCE identification

### Exploitation

Command injection via `plot=` parameter · web portal credential discovery (HTML comments, `robots.txt`, log files) · authenticated command execution via web panel · Hydra-style brute force concepts

### Privilege Escalation

`sudo -l` enumeration · SUID binary abuse (`/usr/bin/find -exec /bin/sh -p`) · credential hunting in shell scripts (`backup.sh`) · GTFOBins workflow

### Evasion & Alternative Paths

`cat` filter bypass via `less` · restricted shell escape techniques · ROT13 decoding of hidden notes · multi-wordlist enumeration strategy

### Social & Wireless

Phishing email header analysis · payload construction · Wi-Fi Pineapple rogue AP demonstration · Flipper Zero sub-GHz / RFID cloning concepts

---

## Lab Environment

```text
┌─────────────────────────────────────────┐
│  Host: Windows laptop                   │
│  ┌───────────────────────────────────┐  │
│  │ VirtualBox                        │  │
│  │   ┌───────────────────────────┐   │  │
│  │   │ Kali Linux 2024.x         │   │  │
│  │   │ (attack box)              │   │  │
│  │   └─────────────┬─────────────┘   │  │
│  └─────────────────┼─────────────────┘  │
└────────────────────┼────────────────────┘
                     │ OpenVPN
                     ▼
         ┌───────────────────────────┐
         │ TryHackMe VPN endpoint    │
         │ tun0 → 10.x.x.x target    │
         │ (Pickle Rick / Boiler /   │
         │  Mr. Robot / etc.)        │
         └───────────────────────────┘
```

- **Attacker:** Kali Linux (pre-built TryHackMe image or official download) on VirtualBox
- **Connectivity:** TryHackMe OpenVPN profile (`openvpn username.ovpn`)
- **Targets:** Ephemeral TryHackMe room VMs with rotating IPs (10.10.x.x)
- **Alternatives demoed:** VMware ESXi, in-browser Attack Box (paid)

---

## Submission Standards (per course requirements)

Every lab / CTF deliverable required:

1. **Step-by-step walkthrough** of the approach
2. **For each step:**
   - Tool used (name)
   - Reason for tool (one-or-two-sentence justification)
   - Expected outcome
   - Real outcome
   - Full-desktop screenshot (not just a terminal window)
3. **Completion screenshot** (e.g., TryHackMe room marked "Completed")
4. **PDF submission** via Moodle

Partial credit was awarded for good documentation even without full completion. The walkthroughs in this repository follow this exact structure, re-rendered in markdown for portfolio presentation.

---

## Navigation

- [weekly-reports/](weekly-reports/) — 11 week-by-week summaries
- [ctf-walkthroughs/](ctf-walkthroughs/) — 3 full CTF writeups
- [references/](references/) — OWASP, methodology, kill chain, legal, tools
- [assignments/](assignments/) — redacted submission index
- [screenshots/](screenshots/) — evidence images
- [scripts/](scripts/) — student-authored commands & helpers
- [scripts-extra/](scripts-extra/) — external / provided scripts

---

_This is a pedagogical portfolio. Every technique was exercised on intentionally vulnerable lab targets. Do not apply these techniques to systems you do not own or have explicit written authorization to test._
