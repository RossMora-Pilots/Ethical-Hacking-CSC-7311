# Week 8 — Midterm: TryHackMe Pickle Rick CTF

> **Date:** 2025-03-03 · **Session type:** Practical midterm exam (invigilated)
> **Deliverable:** Graded CTF walkthrough (PDF via Moodle)

## Session Overview

Week 8 was the **practical midterm exam** — a live, invigilated CTF conducted during class time (17:30–20:30). Students completed the [TryHackMe Pickle Rick](https://tryhackme.com/room/picklerick) room individually while the instructor monitored via Zoom screen-share.

> [!IMPORTANT]
> This was the first time all course concepts were tested together in a time-pressured, unguided scenario. No hints, no walkthrough — just the target machine and the methodology.

## Exam Conditions

| Aspect | Detail |
|---|---|
| **Format** | Individual practical CTF |
| **Time limit** | ~3 hours (class session) |
| **Proctoring** | In-class + Zoom screen-share |
| **Open book** | Yes — internet access, notes, and tools permitted |
| **Submission** | PDF walkthrough via Moodle by end of session |
| **Grading** | Step-by-step documentation quality + completion |

## Approach Taken

The midterm applied the six-phase methodology drilled in Weeks 1–6:

1. **Nmap full-port scan** to identify the attack surface (SSH + HTTP)
2. **HTML source inspection** → username discovered in comments
3. **robots.txt** → password discovered
4. **Gobuster + Nikto** → hidden web paths (`/portal.php`)
5. **Authenticated command execution** → first two ingredients
6. **sudo -l → NOPASSWD: ALL** → third ingredient from `/root/`

Total time from first Nmap scan to final flag: approximately **45 minutes**.

## Key Takeaway

> The midterm proved that systematic methodology works. No guessing was required — every step followed logically from the previous one. The hardest part was documenting each step thoroughly while working under time pressure.

## Full Walkthrough

→ **[Pickle Rick CTF — Complete Walkthrough](../ctf-walkthroughs/midterm-pickle-rick.md)**

---

_Previous:_ [Week 6 — Network Services](week-06-network-services.md) · _Next:_ [Week 10 — Phishing](week-10-phishing.md)
